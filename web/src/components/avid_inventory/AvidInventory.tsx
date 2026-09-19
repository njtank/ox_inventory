import React, { useCallback, useEffect, useMemo, useState } from 'react';
import { useDrag, useDrop } from 'react-dnd';
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
  pockets: GridInventory;
  backpack?: GridInventory | null;
  equipment: Record<string, AvidItem>;
  equipmentSlots: Record<string, { label: string }>;
};
type ActionResponse = { success: boolean; error?: string; state?: AvidState };
type DragPayload = { kind: GridName; slot: number; rotated: boolean };
type Selection = { kind: GridName; slot: number };

const DRAG_TYPE = 'AVID_SPATIAL_ITEM';
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
  onDropItem: (source: GridName, target: GridName, slot: number, x: number, y: number, rotated: boolean) => void;
}> = ({ index, inventory, kind, onDropItem }) => {
  const x = (index % inventory.cols) + 1;
  const y = Math.floor(index / inventory.cols) + 1;
  const [{ over }, drop] = useDrop<DragPayload, void, { over: boolean }>(() => ({
    accept: DRAG_TYPE,
    drop: (source) => onDropItem(source.kind, kind, source.slot, x, y, source.rotated),
    collect: (monitor) => ({ over: monitor.isOver({ shallow: true }) }),
  }), [kind, x, y, onDropItem]);

  return <div ref={(node) => drop(node)} className={`avid-cell ${over ? 'is-over' : ''}`} />;
};

const Item: React.FC<{
  item: AvidItem;
  kind: GridName;
  selected: boolean;
  muted: boolean;
  onSelect: () => void;
  onUse: () => void;
}> = ({ item, kind, selected, muted, onSelect, onUse }) => {
  const grid = item.avid?.grid;
  const [{ dragging }, drag] = useDrag<DragPayload, void, { dragging: boolean }>(() => ({
    type: DRAG_TYPE,
    item: { kind, slot: item.slot, rotated: grid?.rotated === true },
    canDrag: Boolean(grid),
    collect: (monitor) => ({ dragging: monitor.isDragging() }),
  }), [kind, item.slot, grid?.rotated]);

  if (!grid) return null;

  return (
    <button
      ref={(node) => drag(node)}
      className={`avid-item ${selected ? 'is-selected' : ''} ${muted ? 'is-muted' : ''} ${dragging ? 'is-dragging' : ''}`}
      style={{
        gridColumn: `${grid.x} / span ${item.width}`,
        gridRow: `${grid.y} / span ${item.height}`,
      }}
      onClick={(e) => {
        onSelect();
        if (e.altKey && kind === 'pockets') onUse();
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
  onSelect: (selection: Selection) => void;
  onUse: (item: AvidItem, kind: GridName) => void;
  onDropItem: (source: GridName, target: GridName, slot: number, x: number, y: number, rotated: boolean) => void;
}> = ({ title, subtitle, inventory, kind, selected, search, onSelect, onUse, onDropItem }) => {
  const cells = useMemo(() => Array.from({ length: inventory.cols * inventory.rows }), [inventory.cols, inventory.rows]);
  const query = search.trim().toLowerCase();

  return (
    <section className="avid-panel avid-grid-panel">
      <header className="avid-panel-head">
        <div><small>{kind === 'pockets' ? 'ON PERSON' : 'PORTABLE STORAGE'}</small><h2>{title}</h2><p>{subtitle}</p></div>
        <Weight value={inventory.weight} max={inventory.maxWeight} />
      </header>
      <div className="avid-grid" style={{
        gridTemplateColumns: `repeat(${inventory.cols}, 1fr)`,
        gridTemplateRows: `repeat(${inventory.rows}, 1fr)`,
      }}>
        {cells.map((_, index) => <Cell key={index} index={index} inventory={inventory} kind={kind} onDropItem={onDropItem} />)}
        {inventory.items.filter((i) => !i.avid?.equipped && i.avid?.grid).map((item) => {
          const match = !query || item.label.toLowerCase().includes(query) || item.name.toLowerCase().includes(query);
          return <Item
            key={item.slot}
            item={item}
            kind={kind}
            selected={selected?.kind === kind && selected.slot === item.slot}
            muted={!match}
            onSelect={() => onSelect({ kind, slot: item.slot })}
            onUse={() => onUse(item, kind)}
          />;
        })}
      </div>
      {!!inventory.overflow?.length && <div className="avid-warning">{inventory.overflow.length} item(s) need free physical space. Nothing was deleted.</div>}
    </section>
  );
};

const Character: React.FC<{
  state: AvidState;
  selected?: AvidItem;
  selectedKind?: GridName;
  update: (next?: AvidState) => void;
  error: (message: string) => void;
}> = ({ state, selected, selectedKind, update, error }) => {
  const equip = async (equipmentSlot: string) => {
    if (!selected || selectedKind !== 'pockets') return;
    const result = await fetchNui<ActionResponse>('avid:equip', { slot: selected.slot, equipmentSlot });
    if (!result?.success) return error(result?.error || 'Unable to equip');
    update(result.state);
  };

  const unequip = async (equipmentSlot: string) => {
    const result = await fetchNui<ActionResponse>('avid:unequip', { equipmentSlot });
    if (!result?.success) return error(result?.error || 'Unable to unequip');
    update(result.state);
  };

  return (
    <section className="avid-panel avid-character">
      <header className="avid-panel-head"><div><small>CHARACTER</small><h2>Equipped</h2><p>What your character actually has ready.</p></div></header>
      <div className="avid-character-body">
        <div className="avid-person" aria-hidden="true"><i /><b /><span /><em /></div>
        <div className="avid-equipment">
          {EQUIPMENT.map((slotName) => {
            const item = state.equipment[slotName];
            const combatEmpty = COMBAT.has(slotName) && !item;
            return (
              <button
                key={slotName}
                className={`${item ? 'has-item' : ''} ${combatEmpty ? 'is-subdued' : ''}`}
                onClick={() => item ? unequip(slotName) : equip(slotName)}
              >
                <small>{state.equipmentSlots[slotName]?.label || slotName}</small>
                {item ? <><img src={itemImage(item)} alt="" /><span>{item.label}</span></> : <span>Empty</span>}
              </button>
            );
          })}
        </div>
      </div>
      <footer>Everyday carry first. Tactical gear only steps forward when your character actually has it.</footer>
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

const AvidInventory: React.FC = () => {
  const dispatch = useAppDispatch();
  const rightInventory = useAppSelector(selectRightInventory);
  const [visible, setVisible] = useState(false);
  const [state, setState] = useState<AvidState | null>(null);
  const [selected, setSelected] = useState<Selection | null>(null);
  const [search, setSearch] = useState('');
  const [notice, setNotice] = useState<string | null>(null);

  const refresh = useCallback(async (next?: AvidState) => {
    if (next) return setState(next);
    const value = await fetchNui<AvidState>('avid:getState');
    if (value) setState(value);
  }, []);

  const show = useCallback((message: string) => {
    const clean = message.replaceAll('_', ' ');
    setNotice(clean);
    window.setTimeout(() => setNotice((v) => v === clean ? null : v), 2400);
  }, []);

  useNuiEvent<boolean>('setInventoryVisible', (v) => { setVisible(v); if (v) void refresh(); });
  useNuiEvent<false>('closeInventory', () => {
    setVisible(false); setSelected(null); dispatch(closeContextMenu()); dispatch(closeTooltip());
  });
  useNuiEvent<{ leftInventory?: OxInventory; rightInventory?: OxInventory }>('setupInventory', (data) => {
    dispatch(setupInventory(data)); setVisible(true); void refresh();
  });
  useNuiEvent('refreshSlots', (data) => { dispatch(refreshSlots(data)); window.setTimeout(() => void refresh(), 35); });
  useNuiEvent('displayMetadata', (data: Array<{ metadata: string; value: string }>) => dispatch(setAdditionalMetadata(data)));
  useExitListener(setVisible);

  const item = useMemo(() => {
    if (!state || !selected) return undefined;
    const inv = selected.kind === 'pockets' ? state.pockets : state.backpack;
    return inv?.items.find((entry) => entry.slot === selected.slot);
  }, [state, selected]);

  const useItem = useCallback(async (entry?: AvidItem, kind?: GridName) => {
    if (!entry || kind !== 'pockets') return;
    await fetchNui('useItem', entry.slot);
    window.setTimeout(() => void refresh(), 35);
  }, [refresh]);

  const giveItem = useCallback(async () => {
    if (!item || selected?.kind !== 'pockets') return;
    await fetchNui('giveItem', { slot: item.slot, count: 0 });
    window.setTimeout(() => void refresh(), 35);
  }, [item, selected, refresh]);

  const move = useCallback(async (source: GridName, target: GridName, slot: number, x: number, y: number, rotated: boolean) => {
    const endpoint = source === target ? 'avid:setGrid' : 'avid:move';
    const payload = source === target
      ? { inventory: target, slot, x, y, rotated }
      : { from: source, to: target, slot, x, y, rotated };

    const result = await fetchNui<ActionResponse>(endpoint, payload);
    if (!result?.success) return show(result?.error || 'Unable to move item');
    if (result.state) setState(result.state); else void refresh();
    setSelected({ kind: target, slot });
  }, [refresh, show]);

  const rotate = useCallback(async () => {
    if (!item?.avid?.grid || !selected) return;
    const grid = item.avid.grid;
    const result = await fetchNui<ActionResponse>('avid:setGrid', {
      inventory: selected.kind, slot: item.slot, x: grid.x, y: grid.y, rotated: !grid.rotated,
    });
    if (!result?.success) return show(result?.error || 'Unable to rotate item');
    if (result.state) setState(result.state); else void refresh();
  }, [item, selected, refresh, show]);

  useEffect(() => {
    const listener = (event: KeyboardEvent) => {
      if (visible && event.key.toLowerCase() === 'r' && item) { event.preventDefault(); void rotate(); }
    };
    window.addEventListener('keydown', listener);
    return () => window.removeEventListener('keydown', listener);
  }, [visible, item, rotate]);

  const externalOpen = Boolean(rightInventory?.id && rightInventory.type && rightInventory.type !== 'newdrop');

  if (!visible) return <InventoryHotbar />;

  return <>
    <div className="avid-ui">
      <header className="avid-top">
        <div><strong>AVID RP</strong><small>MORE THAN A CITY</small></div>
        <nav><span>Inventory</span><span>Character</span><span>Storage</span></nav>
        <button onClick={() => fetchNui('exit')}>×</button>
      </header>

      <div className="avid-toolbar">
        <label><span>⌕</span><input value={search} onChange={(e) => setSearch(e.target.value)} placeholder="Search what you're carrying..." /></label>
        <div><kbd>R</kbd> Rotate · <kbd>ALT</kbd> + click Use · Double-click Use</div>
      </div>

      {state ? (
        externalOpen ? (
          <div className="avid-external-layout">
            <Character state={state} selected={item} selectedKind={selected?.kind} update={(v) => v ? setState(v) : void refresh()} error={show} />
            <section className="avid-panel avid-stock-transfer">
              <header className="avid-panel-head"><div><small>TRANSFER</small><h2>{rightInventory.label || 'Storage'}</h2><p>External inventories keep ox's proven transfer rules while Avid spatial layouts are added per container type.</p></div></header>
              <div className="avid-stock-inner"><LeftInventory /><InventoryControl /><RightInventory /></div>
            </section>
          </div>
        ) : (
          <div className="avid-layout">
            <Character state={state} selected={item} selectedKind={selected?.kind} update={(v) => v ? setState(v) : void refresh()} error={show} />
            <Grid title="Pockets" subtitle="The things you can actually carry on your person." inventory={state.pockets} kind="pockets" selected={selected} search={search} onSelect={setSelected} onUse={useItem} onDropItem={move} />
            <div className="avid-right">
              {state.backpack
                ? <Grid title={state.backpack.label || 'Backpack'} subtitle="A separate physical container." inventory={state.backpack} kind="backpack" selected={selected} search={search} onSelect={setSelected} onUse={useItem} onDropItem={move} />
                : <section className="avid-panel avid-no-bag"><div>▱</div><h2>No bag equipped</h2><p>Equip a backpack to add portable storage.</p></section>}
              <Details item={item} kind={selected?.kind} onRotate={() => void rotate()} onUse={() => void useItem(item, selected?.kind)} onGive={() => void giveItem()} />
            </div>
          </div>
        )
      ) : <div className="avid-loading">Loading Avid inventory…</div>}

      <footer className="avid-footer"><span>LOS SANTOS, A DIFFERENT KIND OF LIFE</span><span>PEOPLE › STORIES › A BETTER LOS SANTOS</span></footer>
      {notice && <div className="avid-toast">{notice}</div>}
      <Tooltip />
      <InventoryContext />
    </div>
    <InventoryHotbar />
  </>;
};

export default AvidInventory;
