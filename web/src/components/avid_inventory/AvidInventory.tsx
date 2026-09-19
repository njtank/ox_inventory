import React, { useCallback, useEffect, useMemo, useState } from 'react';
import useNuiEvent from '../../hooks/useNuiEvent';
import { useExitListener } from '../../hooks/useExitListener';
import { useAppDispatch, useAppSelector } from '../../store';
import {
  refreshSlots,
  selectRightInventory,
  setAdditionalMetadata,
  setupInventory,
} from '../../store/inventory';
import type { Inventory as OxInventory } from '../../typings';
import { fetchNui } from '../../utils/fetchNui';
import { getItemUrl } from '../../helpers';
import InventoryHotbar from '../inventory/InventoryHotbar';
import InventoryControl from '../inventory/InventoryControl';
import LeftInventory from '../inventory/LeftInventory';
import RightInventory from '../inventory/RightInventory';
import Tooltip from '../utils/Tooltip';
import InventoryContext from '../inventory/InventoryContext';
import { closeTooltip } from '../../store/tooltip';
import { closeContextMenu } from '../../store/contextMenu';
import './avid-inventory.scss';

type GridName = 'pockets' | 'backpack';
type GridPosition = { x: number; y: number; rotated?: boolean };
type AvidItem = {
  slot: number;
  name: string;
  label: string;
  count: number;
  weight: number;
  width: number;
  height: number;
  metadata: Record<string, any>;
  avid: { version?: number; grid?: GridPosition; equipped?: string };
  compatibleEquipment?: string[];
};
type GridInventory = {
  id: string | number;
  type?: string;
  label?: string;
  cols: number;
  rows: number;
  weight: number;
  maxWeight: number;
  overflow: number[];
  items: AvidItem[];
};
type AvidState = {
  character?: { name?: string; sex?: string | number };
  pockets: GridInventory;
  backpack?: GridInventory | null;
  equipment: Record<string, AvidItem>;
  equipmentSlots: Record<string, { label: string }>;
};
type ActionResponse = { success: boolean; error?: string; state?: AvidState };
type DragPayload = { source: 'grid' | 'equipment'; kind?: GridName; slot: number; rotated: boolean; equipmentSlot?: string };
type Selection = { kind: GridName; slot: number };
type ViewName = 'inventory' | 'character' | 'storage';
type ContextState = { x: number; y: number; item: AvidItem; kind: GridName | 'equipment'; equipmentSlot?: string } | null;
const EQUIPMENT = ['phone', 'radio', 'backpack', 'armor', 'primary', 'secondary', 'melee'];
const COMBAT = new Set(['armor', 'primary', 'secondary', 'melee']);
const browser = !(window as any).GetParentResourceName;
const kg = (grams = 0) => `${(grams / 1000).toFixed(1)} kg`;

const itemImage = (item: Pick<AvidItem, 'name' | 'metadata'>) => {
  try {
    return getItemUrl({ name: item.name, metadata: item.metadata || {} } as any);
  } catch {
    return `nui://ox_inventory/web/images/${item.name}.png`;
  }
};

const Weight: React.FC<{ value: number; max: number }> = ({ value, max }) => {
  const percent = max > 0 ? Math.min(100, (value / max) * 100) : 0;
  return (
    <div className="avid-weight">
      <div><span>{kg(value)}</span><span>{kg(max)}</span></div>
      <i><b style={{ width: `${percent}%` }} /></i>
    </div>
  );
};

const Cell: React.FC<{
  index: number;
  inventory: GridInventory;
  kind: GridName;
  dragging: DragPayload | null;
  onDropItem: (payload: DragPayload, target: GridName, x: number, y: number) => void;
}> = ({ index, inventory, kind, dragging, onDropItem }) => {
  const [over, setOver] = useState(false);
  const x = (index % inventory.cols) + 1;
  const y = Math.floor(index / inventory.cols) + 1;

  return (
    <div
      className={'avid-cell ' + (over ? 'is-over' : '')}
      onDragEnter={(event) => {
        if (!dragging) return;
        event.preventDefault();
        setOver(true);
      }}
      onDragOver={(event) => {
        if (!dragging) return;
        event.preventDefault();
        event.dataTransfer.dropEffect = 'move';
      }}
      onDragLeave={() => setOver(false)}
      onDrop={(event) => {
        event.preventDefault();
        setOver(false);
        if (dragging) onDropItem(dragging, kind, x, y);
      }}
    />
  );
};

const Item: React.FC<{
  item: AvidItem;
  kind: GridName;
  selected: boolean;
  muted: boolean;
  onSelect: () => void;
  onUse: () => void;
  onDragStart: (payload: DragPayload) => void;
  onDragEnd: () => void;
  onContext: (event: React.MouseEvent) => void;
}> = ({ item, kind, selected, muted, onSelect, onUse, onDragStart, onDragEnd, onContext }) => {
  const grid = item.avid?.grid;
  if (!grid) return null;

  return (
    <button
      draggable
      className={'avid-item ' + (selected ? 'is-selected ' : '') + (muted ? 'is-muted' : '')}
      style={{
        gridColumn: grid.x + ' / span ' + item.width,
        gridRow: grid.y + ' / span ' + item.height,
      }}
      onDragStart={(event) => {
        const payload: DragPayload = { source: 'grid', kind, slot: item.slot, rotated: grid.rotated === true };
        event.dataTransfer.effectAllowed = 'move';
        event.dataTransfer.setData('text/plain', item.name);
        onDragStart(payload);
        onSelect();
      }}
      onDragEnd={onDragEnd}
      onContextMenu={onContext}
      onClick={(event) => {
        onSelect();
        if (event.altKey && kind === 'pockets') onUse();
      }}
      onDoubleClick={() => kind === 'pockets' && onUse()}
    >
      <img src={itemImage(item)} alt="" draggable={false} />
      {item.count > 1 && <em>{item.count}x</em>}
      <span>{item.label}</span>
    </button>
  );
};

const Grid: React.FC<{
  title: string;
  subtitle: string;
  inventory: GridInventory;
  kind: GridName;
  selected: Selection | null;
  search: string;
  dragging: DragPayload | null;
  onSelect: (selection: Selection) => void;
  onUse: (item: AvidItem, kind: GridName) => void;
  onDragStart: (payload: DragPayload) => void;
  onDragEnd: () => void;
  onContext: (event: React.MouseEvent, item: AvidItem, kind: GridName) => void;
  onDropItem: (payload: DragPayload, target: GridName, x: number, y: number) => void;
}> = ({ title, subtitle, inventory, kind, selected, search, dragging, onSelect, onUse, onDragStart, onDragEnd, onContext, onDropItem }) => {
  const cells = useMemo(() => Array.from({ length: inventory.cols * inventory.rows }), [inventory.cols, inventory.rows]);
  const query = search.trim().toLowerCase();

  return (
    <section className="avid-panel avid-grid-panel">
      <header className="avid-panel-head">
        <div><small>{kind === 'pockets' ? 'ON PERSON' : 'PORTABLE STORAGE'}</small><h2>{title}</h2><p>{subtitle}</p></div>
        <Weight value={inventory.weight} max={inventory.maxWeight} />
      </header>
      <div
        className="avid-grid"
        style={{
          gridTemplateColumns: 'repeat(' + inventory.cols + ', 1fr)',
          gridTemplateRows: 'repeat(' + inventory.rows + ', 1fr)',
        }}
      >
        {cells.map((_, index) => (
          <Cell key={index} index={index} inventory={inventory} kind={kind} dragging={dragging} onDropItem={onDropItem} />
        ))}
        {inventory.items.filter((entry) => !entry.avid?.equipped && entry.avid?.grid).map((entry) => {
          const match = !query || entry.label.toLowerCase().includes(query) || entry.name.toLowerCase().includes(query);
          return (
            <Item
              key={entry.slot}
              item={entry}
              kind={kind}
              selected={selected?.kind === kind && selected.slot === entry.slot}
              muted={!match}
              onSelect={() => onSelect({ kind, slot: entry.slot })}
              onUse={() => onUse(entry, kind)}
              onDragStart={onDragStart}
              onDragEnd={onDragEnd}
              onContext={(event) => onContext(event, entry, kind)}
            />
          );
        })}
      </div>
      {!!inventory.overflow?.length && (
        <div className="avid-warning">{inventory.overflow.length} item(s) need free physical space. Nothing was deleted.</div>
      )}
    </section>
  );
};

const Character: React.FC<{
  state: AvidState;
  dragging: DragPayload | null;
  onEquipDrop: (slotName: string, payload: DragPayload) => void;
  onUnequip: (slotName: string) => void;
  onDragStart: (payload: DragPayload) => void;
  onDragEnd: () => void;
  onContext: (event: React.MouseEvent, item: AvidItem, equipmentSlot: string) => void;
}> = ({ state, dragging, onEquipDrop, onUnequip, onDragStart, onDragEnd, onContext }) => {
  const characterName = state.character?.name || 'Your Character';

  return (
    <section className="avid-panel avid-character">
      <header className="avid-panel-head">
        <div><small>CHARACTER</small><h2>{characterName}</h2><p>What your character actually has ready.</p></div>
      </header>
      <div className="avid-character-body">
        <div className="avid-avatar" aria-label={characterName}>
          <div className="avatar-hair" />
          <div className="avatar-head"><i /><b /></div>
          <div className="avatar-neck" />
          <div className="avatar-torso"><span /></div>
          <div className="avatar-arm left" />
          <div className="avatar-arm right" />
          <div className="avatar-leg left" />
          <div className="avatar-leg right" />
          <div className="avatar-shoe left" />
          <div className="avatar-shoe right" />
          <small>{characterName}</small>
        </div>

        <div className="avid-equipment">
          {EQUIPMENT.map((slotName) => {
            const equippedItem = state.equipment[slotName];
            const compatible = dragging?.source === 'grid' && dragging.kind === 'pockets'
              ? state.pockets.items.find((entry) => entry.slot === dragging.slot)?.compatibleEquipment?.includes(slotName)
              : false;
            const combatEmpty = COMBAT.has(slotName) && !equippedItem;

            return (
              <button
                key={slotName}
                draggable={Boolean(equippedItem)}
                className={
                  (equippedItem ? 'has-item ' : '') +
                  (combatEmpty ? 'is-subdued ' : '') +
                  (compatible ? 'is-compatible' : '')
                }
                onDragStart={(event) => {
                  if (!equippedItem) {
                    event.preventDefault();
                    return;
                  }
                  event.dataTransfer.effectAllowed = 'move';
                  onDragStart({ source: 'equipment', slot: equippedItem.slot, rotated: false, equipmentSlot: slotName });
                }}
                onDragEnd={onDragEnd}
                onDragOver={(event) => {
                  if (compatible) {
                    event.preventDefault();
                    event.dataTransfer.dropEffect = 'move';
                  }
                }}
                onDrop={(event) => {
                  event.preventDefault();
                  if (compatible && dragging) onEquipDrop(slotName, dragging);
                }}
                onContextMenu={(event) => equippedItem && onContext(event, equippedItem, slotName)}
                onDoubleClick={() => equippedItem && onUnequip(slotName)}
              >
                <small>{state.equipmentSlots[slotName]?.label || slotName}</small>
                {equippedItem
                  ? <><img src={itemImage(equippedItem)} alt="" /><span>{equippedItem.label}</span></>
                  : <span>{compatible ? 'Drop to equip' : 'Empty'}</span>}
              </button>
            );
          })}
        </div>
      </div>
      <footer>Drag compatible items onto equipment slots. Double-click equipped items to return them to your pockets.</footer>
    </section>
  );
};

const Details: React.FC<{
  item?: AvidItem;
  kind?: GridName;
  onRotate: () => void;
  onUse: () => void;
  onGive: () => void;
}> = ({ item, kind, onRotate, onUse, onGive }) => (
  <section className="avid-panel avid-details">
    <header className="avid-panel-head"><div><small>ITEM</small><h2>{item?.label || 'Nothing selected'}</h2><p>{item ? `${item.width}x${item.height} footprint · ${kg(item.weight)}` : 'Select an item to inspect it.'}</p></div></header>
    {item ? <div className="avid-detail-content">
      <img src={itemImage(item)} alt="" />
      <div><strong>{item.label}</strong><small>{item.name}</small>{item.metadata?.description && <p>{String(item.metadata.description)}</p>}</div>
      <div className="avid-actions">
        <button onClick={onRotate}>R · Rotate</button>
        <button onClick={onUse} disabled={kind !== 'pockets'}>Use</button>
        <button onClick={onGive} disabled={kind !== 'pockets'}>Give</button>
      </div>
    </div> : <div className="avid-empty-details">Drag items to repack. Press R to rotate the selected item.</div>}
  </section>
);


const ContextMenu: React.FC<{
  context: ContextState;
  onClose: () => void;
  onUse: () => void;
  onGive: () => void;
  onRotate: () => void;
  onEquip: (slot: string) => void;
  onUnequip: () => void;
}> = ({ context, onClose, onUse, onGive, onRotate, onEquip, onUnequip }) => {
  if (!context) return null;

  const equipment = context.item.compatibleEquipment || [];

  return (
    <div className="avid-context-backdrop" onMouseDown={onClose}>
      <div
        className="avid-context-menu"
        style={{ left: context.x, top: context.y }}
        onMouseDown={(event) => event.stopPropagation()}
      >
        <div className="avid-context-head">
          <img src={itemImage(context.item)} alt="" />
          <div><strong>{context.item.label}</strong><small>{context.item.name}</small></div>
        </div>
        <div className="avid-context-meta">
          <span>{context.item.width}x{context.item.height}</span>
          <span>{kg(context.item.weight)}</span>
          {context.item.metadata?.durability !== undefined && <span>Durability {String(context.item.metadata.durability)}</span>}
        </div>

        {context.kind === 'equipment' ? (
          <button onClick={onUnequip}>Return to pockets</button>
        ) : (
          <>
            <button onClick={onUse} disabled={context.kind !== 'pockets'}>Use</button>
            <button onClick={onGive} disabled={context.kind !== 'pockets'}>Give</button>
            <button onClick={onRotate}>Rotate</button>
            {context.kind === 'pockets' && equipment.map((slot) => (
              <button key={slot} onClick={() => onEquip(slot)}>Equip · {slot}</button>
            ))}
          </>
        )}
      </div>
    </div>
  );
};

const AvidInventory: React.FC = () => {
  const dispatch = useAppDispatch();
  const rightInventory = useAppSelector(selectRightInventory);
  const [visible, setVisible] = useState(false);
  const [state, setState] = useState<AvidState | null>(null);
  const [selected, setSelected] = useState<Selection | null>(null);
  const [search, setSearch] = useState('');
  const [notice, setNotice] = useState<string | null>(null);
  const [view, setView] = useState<ViewName>('inventory');
  const [dragging, setDragging] = useState<DragPayload | null>(null);
  const [context, setContext] = useState<ContextState>(null);

  const refresh = useCallback(async (next?: AvidState) => {
    if (next) {
      setState(next);
      return;
    }

    const value = await fetchNui<AvidState>('avid:getState');
    if (value) setState(value);
  }, []);

  const show = useCallback((message: string) => {
    const clean = message.replaceAll('_', ' ');
    setNotice(clean);
    window.setTimeout(() => setNotice((value) => value === clean ? null : value), 2400);
  }, []);

  useNuiEvent<boolean>('setInventoryVisible', (value) => {
    setVisible(value);
    if (value) void refresh();
  });

  useNuiEvent<false>('closeInventory', () => {
    setVisible(false);
    setSelected(null);
    setDragging(null);
    setContext(null);
    dispatch(closeContextMenu());
    dispatch(closeTooltip());
  });

  useNuiEvent<{ leftInventory?: OxInventory; rightInventory?: OxInventory }>('setupInventory', (data) => {
    dispatch(setupInventory(data));
    setVisible(true);
    if (data.rightInventory?.id) setView('storage');
    void refresh();
  });

  useNuiEvent('refreshSlots', (data) => {
    dispatch(refreshSlots(data));
    window.setTimeout(() => void refresh(), 35);
  });

  useNuiEvent('displayMetadata', (data: Array<{ metadata: string; value: string }>) => dispatch(setAdditionalMetadata(data)));
  useExitListener(setVisible);

  const item = useMemo(() => {
    if (!state || !selected) return undefined;
    const inventory = selected.kind === 'pockets' ? state.pockets : state.backpack;
    return inventory?.items.find((entry) => entry.slot === selected.slot);
  }, [state, selected]);

  const useItem = useCallback(async (entry?: AvidItem, kind?: GridName) => {
    if (!entry || kind !== 'pockets') return;
    await fetchNui('useItem', entry.slot);
    window.setTimeout(() => void refresh(), 35);
  }, [refresh]);

  const giveSpecificItem = useCallback(async (entry?: AvidItem, kind?: GridName | 'equipment') => {
    if (!entry || kind !== 'pockets') return;
    await fetchNui('giveItem', { slot: entry.slot, count: 0 });
    window.setTimeout(() => void refresh(), 35);
  }, [refresh]);

  const giveItem = useCallback(async () => {
    await giveSpecificItem(item, selected?.kind);
  }, [giveSpecificItem, item, selected]);

  const rotateItem = useCallback(async (entry?: AvidItem, kind?: GridName) => {
    if (!entry?.avid?.grid || !kind) return;

    const grid = entry.avid.grid;
    const result = await fetchNui<ActionResponse>('avid:setGrid', {
      inventory: kind,
      slot: entry.slot,
      x: grid.x,
      y: grid.y,
      rotated: !grid.rotated,
    });

    if (!result?.success) return show(result?.error || 'Unable to rotate item');
    if (result.state) setState(result.state); else void refresh();
  }, [refresh, show]);

  const rotate = useCallback(async () => {
    await rotateItem(item, selected?.kind);
  }, [item, selected, rotateItem]);

  const dropOnGrid = useCallback(async (payload: DragPayload, target: GridName, x: number, y: number) => {
    if (payload.source === 'equipment') {
      if (target !== 'pockets') {
        show('Equipped items return to pockets first');
        return;
      }

      const result = await fetchNui<ActionResponse>('avid:unequipToGrid', {
        slot: payload.slot,
        x,
        y,
        rotated: payload.rotated,
      });

      if (!result?.success) return show(result?.error || 'Unable to unequip item');
      if (result.state) setState(result.state); else void refresh();
      setSelected({ kind: 'pockets', slot: payload.slot });
      return;
    }

    if (!payload.kind) return;

    const endpoint = payload.kind === target ? 'avid:setGrid' : 'avid:move';
    const request = payload.kind === target
      ? { inventory: target, slot: payload.slot, x, y, rotated: payload.rotated }
      : { from: payload.kind, to: target, slot: payload.slot, x, y, rotated: payload.rotated };

    const result = await fetchNui<ActionResponse>(endpoint, request);
    if (!result?.success) return show(result?.error || 'Unable to move item');

    if (result.state) setState(result.state); else void refresh();

    const moved = result.state
      ? (target === 'pockets' ? result.state.pockets : result.state.backpack)?.items.find((entry) => entry.name && entry.slot !== undefined && (
          payload.kind === target ? entry.slot === payload.slot : entry.name === (
            payload.kind === 'pockets'
              ? state?.pockets.items.find((source) => source.slot === payload.slot)?.name
              : state?.backpack?.items.find((source) => source.slot === payload.slot)?.name
          )
        ))
      : undefined;

    setSelected({ kind: target, slot: moved?.slot ?? payload.slot });
  }, [refresh, show, state]);

  const equipItem = useCallback(async (equipmentSlot: string, entry?: AvidItem, kind?: GridName) => {
    if (!entry || kind !== 'pockets') {
      show('Items must be in your pockets before equipping');
      return;
    }

    const result = await fetchNui<ActionResponse>('avid:equip', { slot: entry.slot, equipmentSlot });
    if (!result?.success) return show(result?.error || 'Unable to equip item');
    if (result.state) setState(result.state); else void refresh();
    setSelected(null);
    setContext(null);
  }, [refresh, show]);

  const equipDrop = useCallback(async (equipmentSlot: string, payload: DragPayload) => {
    if (payload.source !== 'grid' || payload.kind !== 'pockets' || !state) return;
    const entry = state.pockets.items.find((candidate) => candidate.slot === payload.slot);
    await equipItem(equipmentSlot, entry, 'pockets');
  }, [equipItem, state]);

  const unequip = useCallback(async (equipmentSlot: string) => {
    const result = await fetchNui<ActionResponse>('avid:unequip', { equipmentSlot });
    if (!result?.success) return show(result?.error || 'Unable to unequip item');
    if (result.state) setState(result.state); else void refresh();
    setContext(null);
  }, [refresh, show]);

  const openContext = useCallback((event: React.MouseEvent, entry: AvidItem, kind: GridName | 'equipment', equipmentSlot?: string) => {
    event.preventDefault();
    event.stopPropagation();

    if (kind !== 'equipment') setSelected({ kind, slot: entry.slot });

    const width = 230;
    const height = 330;
    const x = Math.min(event.clientX, window.innerWidth - width - 12);
    const y = Math.min(event.clientY, window.innerHeight - height - 12);
    setContext({ x, y, item: entry, kind, equipmentSlot });
  }, []);

  useEffect(() => {
    const listener = (event: KeyboardEvent) => {
      if (!visible) return;

      if (event.key.toLowerCase() === 'r' && item) {
        event.preventDefault();
        void rotate();
      }

      if (event.key === 'Escape' && context) {
        event.preventDefault();
        setContext(null);
      }
    };

    window.addEventListener('keydown', listener);
    return () => window.removeEventListener('keydown', listener);
  }, [visible, item, rotate, context]);

  const externalOpen = Boolean(rightInventory?.id && rightInventory.type && rightInventory.type !== 'newdrop');

  const gridProps = {
    selected,
    search,
    dragging,
    onSelect: setSelected,
    onUse: useItem,
    onDragStart: setDragging,
    onDragEnd: () => setDragging(null),
    onContext: openContext,
    onDropItem: dropOnGrid,
  };

  const characterPanel = state ? (
    <Character
      state={state}
      dragging={dragging}
      onEquipDrop={equipDrop}
      onUnequip={unequip}
      onDragStart={setDragging}
      onDragEnd={() => setDragging(null)}
      onContext={(event, entry, equipmentSlot) => openContext(event, entry, 'equipment', equipmentSlot)}
    />
  ) : null;

  const backpackPanel = state?.backpack ? (
    <Grid
      title={state.backpack.label || 'Backpack'}
      subtitle="A separate physical container tied to the bag you equipped."
      inventory={state.backpack}
      kind="backpack"
      {...gridProps}
    />
  ) : (
    <section className="avid-panel avid-no-bag">
      <div>▱</div>
      <h2>No bag equipped</h2>
      <p>Drag a backpack from your pockets onto the Bag equipment slot.</p>
    </section>
  );

  if (!visible) return <InventoryHotbar />;

  return (
    <>
      <div className="avid-ui" onContextMenu={(event) => event.preventDefault()}>
        <header className="avid-top">
          <div><strong>AVID RP</strong><small>MORE THAN A CITY</small></div>

          <nav>
            <button className={view === 'inventory' ? 'is-active' : ''} onClick={() => setView('inventory')}>Inventory</button>
            <button className={view === 'character' ? 'is-active' : ''} onClick={() => setView('character')}>Character</button>
            <button className={view === 'storage' ? 'is-active' : ''} onClick={() => setView('storage')}>Storage</button>
          </nav>

          <button onClick={() => fetchNui('exit')}>×</button>
        </header>

        <div className="avid-toolbar">
          <label>
            <span>⌕</span>
            <input value={search} onChange={(event) => setSearch(event.target.value)} placeholder="Search what you're carrying..." />
          </label>
          <div><kbd>R</kbd> Rotate · <kbd>RMB</kbd> Item menu · Double-click Use · Drag to equip</div>
        </div>

        {!state ? (
          <div className="avid-loading">Loading Avid inventory…</div>
        ) : view === 'inventory' ? (
          <div className="avid-layout">
            {characterPanel}
            <Grid
              title="Pockets"
              subtitle="The things you can actually carry on your person."
              inventory={state.pockets}
              kind="pockets"
              {...gridProps}
            />
            <div className="avid-right">
              {backpackPanel}
              <Details
                item={item}
                kind={selected?.kind}
                onRotate={() => void rotate()}
                onUse={() => void useItem(item, selected?.kind)}
                onGive={() => void giveItem()}
              />
            </div>
          </div>
        ) : view === 'character' ? (
          <div className="avid-character-view">
            {characterPanel}
            <div className="avid-character-pockets">
              <Grid
                title="Ready to Equip"
                subtitle="Drag compatible items from here onto your character."
                inventory={state.pockets}
                kind="pockets"
                {...gridProps}
              />
            </div>
            <Details
              item={item}
              kind={selected?.kind}
              onRotate={() => void rotate()}
              onUse={() => void useItem(item, selected?.kind)}
              onGive={() => void giveItem()}
            />
          </div>
        ) : externalOpen ? (
          <div className="avid-external-layout">
            {characterPanel}
            <section className="avid-panel avid-stock-transfer">
              <header className="avid-panel-head">
                <div>
                  <small>STORAGE</small>
                  <h2>{rightInventory.label || 'External Storage'}</h2>
                  <p>External storage keeps ox transfer behavior while native Avid spatial layouts are migrated.</p>
                </div>
              </header>
              <div className="avid-stock-inner"><LeftInventory /><InventoryControl /><RightInventory /></div>
            </section>
          </div>
        ) : (
          <div className="avid-storage-view">
            <Grid
              title="Pockets"
              subtitle="Drag items between your person and your equipped bag."
              inventory={state.pockets}
              kind="pockets"
              {...gridProps}
            />
            {backpackPanel}
            <Details
              item={item}
              kind={selected?.kind}
              onRotate={() => void rotate()}
              onUse={() => void useItem(item, selected?.kind)}
              onGive={() => void giveItem()}
            />
          </div>
        )}

        <footer className="avid-footer">
          <span>LOS SANTOS, A DIFFERENT KIND OF LIFE</span>
          <span>PEOPLE › STORIES › A BETTER LOS SANTOS</span>
        </footer>

        {notice && <div className="avid-toast">{notice}</div>}

        <ContextMenu
          context={context}
          onClose={() => setContext(null)}
          onUse={() => {
            if (context) void useItem(context.item, context.kind === 'equipment' ? undefined : context.kind);
            setContext(null);
          }}
          onGive={() => {
            if (context) void giveSpecificItem(context.item, context.kind);
            setContext(null);
          }}
          onRotate={() => {
            if (context && context.kind !== 'equipment') void rotateItem(context.item, context.kind);
            setContext(null);
          }}
          onEquip={(slot) => {
            if (context && context.kind !== 'equipment') void equipItem(slot, context.item, context.kind);
          }}
          onUnequip={() => {
            if (context?.equipmentSlot) void unequip(context.equipmentSlot);
          }}
        />

        <Tooltip />
        <InventoryContext />
      </div>

      <InventoryHotbar />
    </>
  );
};

export default AvidInventory;
