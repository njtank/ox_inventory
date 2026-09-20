import React, { useCallback, useEffect, useMemo, useRef, useState } from 'react';
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

type GridName = 'pockets' | 'backpack' | 'external' | 'searched' | 'searchedBackpack';
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
  external?: GridInventory | null;
  searched?: {
    id: string | number;
    name: string;
    pockets: GridInventory;
    equipment: Record<string, AvidItem>;
    backpack?: GridInventory | null;
  } | null;
  equipment: Record<string, AvidItem>;
  equipmentSlots: Record<string, { label: string }>;
  ground?: {
    id: string | number;
    label?: string;
    slots: number;
    weight: number;
    maxWeight: number;
    items: AvidItem[];
  } | null;
};

type ActionResponse = { success: boolean; error?: string; state?: AvidState };
type DragPayload = {
  source: 'grid' | 'equipment' | 'ground';
  kind?: GridName;
  slot: number;
  rotated: boolean;
  equipmentSlot?: string;
};
type Selection = { kind: GridName; slot: number };
type ContextState = {
  x: number;
  y: number;
  item: AvidItem;
  kind: GridName | 'equipment' | 'searchedEquipment';
  equipmentSlot?: string;
} | null;
type PointerSession = {
  payload: DragPayload;
  item: AvidItem;
  startX: number;
  startY: number;
  active: boolean;
};

const EQUIPMENT = ['phone', 'radio', 'backpack', 'armor', 'primary', 'secondary', 'melee'];
const COMBAT = new Set(['armor', 'primary', 'secondary', 'melee']);
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
  const stateClass = percent >= 98 ? 'is-full' : percent >= 80 ? 'is-heavy' : '';

  return (
    <div className={'avid-weight ' + stateClass}>
      <div><span>{kg(value)}</span><span>{kg(max)}</span></div>
      <i><b style={{ width: `${percent}%` }} /></i>
    </div>
  );
};

const Grid: React.FC<{
  title: string;
  subtitle: string;
  inventory: GridInventory;
  kind: GridName;
  selected: Selection | null;
  search: string;
  onSearch: (value: string) => void;
  dragging: DragPayload | null;
  onSelect: (selection: Selection) => void;
  onUse: (item: AvidItem, kind: GridName) => void;
  onQuickMove: (item: AvidItem, kind: GridName) => void;
  onPointerStart: (event: React.PointerEvent, payload: DragPayload, item: AvidItem) => void;
  onContext: (event: React.MouseEvent, item: AvidItem, kind: GridName) => void;
}> = ({ title, subtitle, inventory, kind, selected, search, onSearch, dragging, onSelect, onUse, onQuickMove, onPointerStart, onContext }) => {
  const cells = useMemo(() => Array.from({ length: inventory.cols * inventory.rows }), [inventory.cols, inventory.rows]);
  const query = search.trim().toLowerCase();

  return (
    <section className={'avid-panel avid-grid-panel is-' + kind}>
      <header className="avid-panel-head avid-grid-head">
        <div className="avid-grid-title">
          <small>{
            kind === 'pockets' ? 'ON PERSON' :
            kind === 'external' ? 'EXTERNAL STORAGE' :
            kind === 'searched' ? 'SEARCHED PERSON' :
            kind === 'searchedBackpack' ? 'SEARCHED BAG' :
            'PORTABLE STORAGE'
          }</small>
          <h2>{title}</h2>
          <p>{subtitle}</p>
        </div>

        {kind === 'pockets' && (
          <label className="avid-grid-search">
            <span>⌕</span>
            <input
              value={search}
              onChange={(event) => onSearch(event.target.value)}
              placeholder="Search inventory..."
            />
          </label>
        )}

        <Weight value={inventory.weight} max={inventory.maxWeight} />
      </header>

      <div
        className={'avid-grid ' + (dragging ? 'is-drag-target' : '')}
        data-grid-container={kind}
        data-grid-cols={inventory.cols}
        data-grid-rows={inventory.rows}
        style={{
          gridTemplateColumns: `repeat(${inventory.cols}, 1fr)`,
          gridTemplateRows: `repeat(${inventory.rows}, 1fr)`,
          aspectRatio: `${inventory.cols} / ${inventory.rows}`,
        }}
      >
        {cells.map((_, index) => {
          const x = (index % inventory.cols) + 1;
          const y = Math.floor(index / inventory.cols) + 1;

          return (
            <div
              key={index}
              className="avid-cell"
              data-grid-kind={kind}
              data-grid-x={x}
              data-grid-y={y}
            />
          );
        })}

        {inventory.items
          .filter((entry) => !entry.avid?.equipped && entry.avid?.grid)
          .map((entry) => {
            const grid = entry.avid.grid!;
            const match = !query || entry.label.toLowerCase().includes(query) || entry.name.toLowerCase().includes(query);
            const isDragging = dragging?.source === 'grid' && dragging.kind === kind && dragging.slot === entry.slot;

            return (
              <button
                key={entry.slot}
                data-item-kind={kind}
                data-item-slot={entry.slot}
                className={
                  'avid-item ' +
                  (selected?.kind === kind && selected.slot === entry.slot ? 'is-selected ' : '') +
                  (!match ? 'is-muted ' : '') +
                  (isDragging ? 'is-dragging ' : '')
                }
                style={{
                  gridColumn: `${grid.x} / span ${entry.width}`,
                  gridRow: `${grid.y} / span ${entry.height}`,
                }}
                onPointerDown={(event) => {
                  if (event.button !== 0) return;
                  onSelect({ kind, slot: entry.slot });
                  if (event.altKey) return;
                  onPointerStart(
                    event,
                    { source: 'grid', kind, slot: entry.slot, rotated: false },
                    entry
                  );
                }}
                onContextMenu={(event) => onContext(event, entry, kind)}
                onClick={(event) => {
                  onSelect({ kind, slot: entry.slot });

                  if (event.altKey) {
                    event.preventDefault();
                    onQuickMove(entry, kind);
                  }
                }}
                onDoubleClick={() => kind === 'pockets' && onUse(entry, kind)}
              >
                <img src={itemImage(entry)} alt="" draggable={false} />
                {entry.count > 1 && <em>{entry.count}x</em>}
                <span>{entry.label}</span>
              </button>
            );
          })}
      </div>

      {!!inventory.overflow?.length && (
        <div className="avid-warning">{inventory.overflow.length} item(s) need free physical space. Nothing was deleted.</div>
      )}
    </section>
  );
};

const EquipmentRail: React.FC<{
  state: AvidState;
  dragging: DragPayload | null;
  onUnequip: (slotName: string) => void;
  onPointerStart: (event: React.PointerEvent, payload: DragPayload, item: AvidItem) => void;
  onContext: (event: React.MouseEvent, item: AvidItem, equipmentSlot: string) => void;
}> = ({ state, dragging, onUnequip, onPointerStart, onContext }) => {
  const characterName = state.character?.name || 'Character';

  return (
    <section className="avid-panel avid-equipment-rail">
      <header className="avid-panel-head avid-equipment-head">
        <div>
          <small>EQUIPMENT</small>
          <h2>{characterName}</h2>
        </div>
      </header>

      <div className="avid-equipment">
        {EQUIPMENT.map((slotName) => {
          const equippedItem = state.equipment[slotName];
          const sourceItem = dragging?.source === 'grid' && dragging.kind === 'pockets'
            ? state.pockets.items.find((entry) => entry.slot === dragging.slot)
            : undefined;
          const compatible = Boolean(sourceItem?.compatibleEquipment?.includes(slotName));
          const combatEmpty = COMBAT.has(slotName) && !equippedItem;

          return (
            <button
              key={slotName}
              data-equipment-slot={slotName}
              className={
                (equippedItem ? 'has-item ' : '') +
                (combatEmpty ? 'is-subdued ' : '') +
                (compatible ? 'is-compatible ' : '') +
                (COMBAT.has(slotName) ? 'is-combat ' : 'is-essential ')
              }
              onPointerDown={(event) => {
                if (event.button !== 0 || !equippedItem) return;

                onPointerStart(
                  event,
                  { source: 'equipment', slot: equippedItem.slot, rotated: false, equipmentSlot: slotName },
                  equippedItem
                );
              }}
              onContextMenu={(event) => equippedItem && onContext(event, equippedItem, slotName)}
              onDoubleClick={() => equippedItem && onUnequip(slotName)}
            >
              <small>{state.equipmentSlots[slotName]?.label || slotName}</small>

              {equippedItem ? (
                <>
                  <img src={itemImage(equippedItem)} alt="" />
                  <span>{equippedItem.label}</span>
                </>
              ) : (
                <span>{compatible ? 'Release to equip' : 'Empty'}</span>
              )}
            </button>
          );
        })}
      </div>

      <div className="avid-equipment-help">
        <kbd>RMB</kbd> options
        <span />
        <kbd>2×</kbd> unequip
      </div>
    </section>
  );
};

const SearchedEquipment: React.FC<{
  name: string;
  equipment: Record<string, AvidItem>;
  equipmentSlots: Record<string, { label: string }>;
  onContext: (event: React.MouseEvent, item: AvidItem, equipmentSlot: string) => void;
}> = ({ name, equipment, equipmentSlots, onContext }) => {
  const occupied = EQUIPMENT.filter((slotName) => equipment[slotName]);

  return (
    <section className="avid-panel avid-search-equipment">
      <header className="avid-panel-head">
        <div>
          <small>SEARCHING</small>
          <h2>{name}</h2>
          <p>Equipped items require explicit confiscation.</p>
        </div>
      </header>

      {occupied.length ? (
        <div className="avid-search-equipment-grid">
          {occupied.map((slotName) => {
            const item = equipment[slotName];

            return (
              <button
                key={slotName}
                onContextMenu={(event) => onContext(event, item, slotName)}
                title="Right-click to confiscate"
              >
                <small>{equipmentSlots[slotName]?.label || slotName}</small>
                <img src={itemImage(item)} alt="" />
                <span>{item.label}</span>
                <em>RMB</em>
              </button>
            );
          })}
        </div>
      ) : (
        <div className="avid-search-empty">No equipped items visible.</div>
      )}
    </section>
  );
};

const GroundPanel: React.FC<{
  ground: NonNullable<AvidState['ground']>;
  dragging: DragPayload | null;
  onPointerStart: (event: React.PointerEvent, payload: DragPayload, item: AvidItem) => void;
}> = ({ ground, dragging, onPointerStart }) => {
  const slots = useMemo(() => Array.from({ length: Math.max(ground.slots || 6, 6) }), [ground.slots]);
  const bySlot = useMemo(() => new Map(ground.items.map((entry) => [entry.slot, entry])), [ground.items]);

  return (
    <section className="avid-panel avid-ground-panel">
      <header className="avid-panel-head">
        <div>
          <small>GROUND</small>
          <h2>{ground.label || 'Nearby Drop'}</h2>
          <p>Drag items between the ground, pockets, and your bag.</p>
        </div>
      </header>

      <div className="avid-ground-scroll">
        <div className="avid-ground-grid">
          {slots.map((_, index) => {
            const slot = index + 1;
            const entry = bySlot.get(slot);
            const isDragging = dragging?.source === 'ground' && dragging.slot === slot;

            return (
              <button
                key={slot}
                className={'avid-ground-slot ' + (entry ? 'has-item ' : '') + (isDragging ? 'is-dragging ' : '')}
                data-ground-slot={slot}
                onPointerDown={(event) => {
                  if (event.button !== 0 || !entry) return;
                  onPointerStart(event, { source: 'ground', slot, rotated: false }, entry);
                }}
              >
                {entry ? (
                  <>
                    <img src={itemImage(entry)} alt="" draggable={false} />
                    {entry.count > 1 && <em>{entry.count}x</em>}
                    <span>{entry.label}</span>
                  </>
                ) : (
                  <small>{slot}</small>
                )}
              </button>
            );
          })}
        </div>
      </div>
    </section>
  );
};

const ContextMenu: React.FC<{
  context: ContextState;
  onClose: () => void;
  onUse: () => void;
  onGive: () => void;
  onDrop: () => void;
  onQuickMove: () => void;
  onSplit: (amount: number) => void;
  onEquip: (slot: string) => void;
  onUnequip: () => void;
  onConfiscate: () => void;
}> = ({ context, onClose, onUse, onGive, onDrop, onQuickMove, onSplit, onEquip, onUnequip, onConfiscate }) => {
  const maxSplit = context ? Math.max(1, context.item.count - 1) : 1;
  const [splitAmount, setSplitAmount] = useState(1);

  useEffect(() => {
    if (!context) return;
    setSplitAmount(Math.max(1, Math.floor(context.item.count / 2)));
  }, [context?.item.slot, context?.item.count, context?.kind]);

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
          <div>
            <strong>{context.item.label}</strong>
            <small>{context.item.name}</small>
          </div>
        </div>

        <div className="avid-context-meta">
          <span>{context.item.width}x{context.item.height}</span>
          <span>{kg(context.item.weight)}</span>
          <span>{context.item.count}x</span>
          {context.item.metadata?.durability !== undefined && (
            <span>Durability {String(context.item.metadata.durability)}</span>
          )}
        </div>

        {context.kind === 'equipment' ? (
          <button onClick={onUnequip}>Return to pockets</button>
        ) : context.kind === 'searchedEquipment' ? (
          <button className="is-confiscate" onClick={onConfiscate}>Confiscate Equipped Item</button>
        ) : (
          <>
            <button onClick={onUse} disabled={context.kind !== 'pockets'}>Use</button>
            <button onClick={onGive} disabled={context.kind !== 'pockets'}>Give</button>
            <button onClick={onQuickMove}>Quick Move</button>

            {context.item.count > 1 &&
              context.kind !== 'searched' &&
              context.kind !== 'searchedBackpack' && (
              <div className="avid-split-control">
                <div>
                  <span>Split Stack</span>
                  <strong>{splitAmount} / {context.item.count}</strong>
                </div>
                <input
                  type="range"
                  min={1}
                  max={maxSplit}
                  value={splitAmount}
                  onChange={(event) => setSplitAmount(Number(event.target.value))}
                />
                <button onClick={() => onSplit(splitAmount)}>Split {splitAmount}</button>
              </div>
            )}

            {(context.kind === 'pockets' || context.kind === 'backpack') && (
              <button className="is-drop" onClick={onDrop}>Drop on ground</button>
            )}

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
  const [dragging, setDragging] = useState<DragPayload | null>(null);
  const [dragVisual, setDragVisual] = useState<{ item: AvidItem; x: number; y: number } | null>(null);
  const [context, setContext] = useState<ContextState>(null);

  const pointerSession = useRef<PointerSession | null>(null);

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
    setDragVisual(null);
    setContext(null);
    pointerSession.current = null;
    dispatch(closeContextMenu());
    dispatch(closeTooltip());
  });

  useNuiEvent<{ leftInventory?: OxInventory; rightInventory?: OxInventory }>('setupInventory', (data) => {
    dispatch(setupInventory(data));
    setVisible(true);
    void refresh();
  });

  useNuiEvent('refreshSlots', (data) => {
    dispatch(refreshSlots(data));
    window.setTimeout(() => void refresh(), 35);
  });

  useNuiEvent('displayMetadata', (data: Array<{ metadata: string; value: string }>) => dispatch(setAdditionalMetadata(data)));
  useExitListener(setVisible);

  const useItem = useCallback(async (entry?: AvidItem, kind?: GridName) => {
    if (!entry || kind !== 'pockets') return;
    await fetchNui('useItem', entry.slot);
    window.setTimeout(() => void refresh(), 35);
  }, [refresh]);

  const giveSpecificItem = useCallback(async (entry?: AvidItem, kind?: GridName | 'equipment' | 'searchedEquipment') => {
    if (!entry || kind !== 'pockets') return;
    await fetchNui('giveItem', { slot: entry.slot, count: 0 });
    window.setTimeout(() => void refresh(), 35);
  }, [refresh]);

  const dropSpecificItem = useCallback(async (entry?: AvidItem, kind?: GridName | 'equipment' | 'searchedEquipment') => {
    if (!entry || (kind !== 'pockets' && kind !== 'backpack')) return;

    const result = await fetchNui<ActionResponse>('avid:drop', {
      from: kind,
      slot: entry.slot,
      count: entry.count,
    });

    if (!result?.success) return show(result?.error || 'Unable to drop item');

    if (result.state) setState(result.state); else void refresh();
    setSelected(null);
    setContext(null);
  }, [refresh, show]);

  const splitStack = useCallback(async (entry: AvidItem, kind: GridName, amount: number) => {
    if ((entry.count || 1) <= 1) return;

    const count = Math.max(1, Math.min(Math.floor(amount), entry.count - 1));

    const result = await fetchNui<ActionResponse>('avid:splitStack', {
      from: kind,
      slot: entry.slot,
      count,
    });

    if (!result?.success) return show(result?.error || 'Unable to split stack');

    if (result.state) setState(result.state); else void refresh();
    setSelected(null);
    setContext(null);
  }, [refresh, show]);

  const mergeStack = useCallback(async (
    payload: DragPayload,
    targetKind: GridName,
    targetSlot: number
  ) => {
    if (payload.source !== 'grid' || !payload.kind) return;

    const result = await fetchNui<ActionResponse>('avid:mergeStack', {
      from: payload.kind,
      fromSlot: payload.slot,
      to: targetKind,
      toSlot: targetSlot,
    });

    if (!result?.success) return show(result?.error || 'Unable to combine stacks');

    if (result.state) setState(result.state); else void refresh();
    setSelected(null);
  }, [refresh, show]);

  const quickMove = useCallback(async (entry: AvidItem, kind: GridName) => {
    const result = await fetchNui<ActionResponse>('avid:quickMove', {
      from: kind,
      slot: entry.slot,
    });

    if (!result?.success) return show(result?.error || 'Unable to quick move item');

    if (result.state) setState(result.state); else void refresh();
    setSelected(null);
    setContext(null);
  }, [refresh, show]);

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
        rotated: false,
      });

      if (!result?.success) return show(result?.error || 'Unable to unequip item');

      if (result.state) setState(result.state); else void refresh();
      setSelected({ kind: 'pockets', slot: payload.slot });
      return;
    }

    if (!payload.kind) return;

    const endpoint = payload.kind === target ? 'avid:setGrid' : 'avid:move';
    const request = payload.kind === target
      ? { inventory: target, slot: payload.slot, x, y, rotated: false }
      : { from: payload.kind, to: target, slot: payload.slot, x, y, rotated: false };

    const result = await fetchNui<ActionResponse>(endpoint, request);

    if (!result?.success) return show(result?.error || 'Unable to move item');
    if (result.state) setState(result.state); else void refresh();

    setSelected(null);
  }, [refresh, show]);


  const groundToGrid = useCallback(async (payload: DragPayload, target: GridName, x: number, y: number) => {
    const result = await fetchNui<ActionResponse>('avid:groundToGrid', {
      slot: payload.slot,
      to: target,
      x,
      y,
      rotated: false,
    });

    if (!result?.success) return show(result?.error || 'Unable to pick up item');
    if (result.state) setState(result.state); else void refresh();
  }, [refresh, show]);

  const gridToGround = useCallback(async (payload: DragPayload, toSlot: number) => {
    if (payload.source !== 'grid' || !payload.kind) return;

    const result = await fetchNui<ActionResponse>('avid:gridToGround', {
      from: payload.kind,
      slot: payload.slot,
      toSlot,
    });

    if (!result?.success) return show(result?.error || 'Unable to move item to ground');
    if (result.state) setState(result.state); else void refresh();
    setSelected(null);
  }, [refresh, show]);

  const confiscateEquipped = useCallback(async (equipmentSlot: string) => {
    const result = await fetchNui<ActionResponse>('avid:confiscateEquipped', { equipmentSlot });

    if (!result?.success) return show(result?.error || 'Unable to confiscate equipped item');

    if (result.state) setState(result.state); else void refresh();
    setSelected(null);
    setContext(null);
  }, [refresh, show]);

  const equipItem = useCallback(async (equipmentSlot: string, entry?: AvidItem, kind?: GridName) => {
    if (!entry || kind !== 'pockets') {
      show('Items must be in your pockets before equipping');
      return;
    }

    const result = await fetchNui<ActionResponse>('avid:equip', {
      slot: entry.slot,
      equipmentSlot,
    });

    if (!result?.success) return show(result?.error || 'Unable to equip item');

    if (result.state) setState(result.state); else void refresh();
    setSelected(null);
    setContext(null);
  }, [refresh, show]);

  const equipDrop = useCallback(async (equipmentSlot: string, payload: DragPayload) => {
    if (payload.source !== 'grid' || payload.kind !== 'pockets' || !state) return;

    const entry = state.pockets.items.find((candidate) => candidate.slot === payload.slot);

    if (!entry?.compatibleEquipment?.includes(equipmentSlot)) {
      show('That item does not fit this equipment slot');
      return;
    }

    await equipItem(equipmentSlot, entry, 'pockets');
  }, [equipItem, show, state]);

  const unequip = useCallback(async (equipmentSlot: string) => {
    const result = await fetchNui<ActionResponse>('avid:unequip', { equipmentSlot });

    if (!result?.success) return show(result?.error || 'Unable to unequip item');

    if (result.state) setState(result.state); else void refresh();
    setContext(null);
  }, [refresh, show]);

  const openContext = useCallback((
    event: React.MouseEvent,
    entry: AvidItem,
    kind: GridName | 'equipment' | 'searchedEquipment',
    equipmentSlot?: string
  ) => {
    event.preventDefault();
    event.stopPropagation();

    if (kind !== 'equipment' && kind !== 'searchedEquipment') setSelected({ kind, slot: entry.slot });

    const width = 230;
    const height = 455;
    const x = Math.min(event.clientX, window.innerWidth - width - 12);
    const y = Math.min(event.clientY, window.innerHeight - height - 12);

    setContext({ x, y, item: entry, kind, equipmentSlot });
  }, []);

  const startPointerDrag = useCallback((
    event: React.PointerEvent,
    payload: DragPayload,
    entry: AvidItem
  ) => {
    pointerSession.current = {
      payload,
      item: entry,
      startX: event.clientX,
      startY: event.clientY,
      active: false,
    };
  }, []);

  useEffect(() => {
    const onMove = (event: PointerEvent) => {
      const session = pointerSession.current;
      if (!session) return;

      const distance = Math.hypot(event.clientX - session.startX, event.clientY - session.startY);

      if (!session.active && distance >= 5) {
        session.active = true;
        setDragging(session.payload);
        setContext(null);
      }

      if (session.active) {
        setDragVisual({ item: session.item, x: event.clientX, y: event.clientY });
      }
    };

    const onUp = (event: PointerEvent) => {
      const session = pointerSession.current;
      pointerSession.current = null;

      if (!session) return;

      if (!session.active) {
        setDragging(null);
        setDragVisual(null);
        return;
      }

      const element = document.elementFromPoint(event.clientX, event.clientY) as HTMLElement | null;
      const equipment = element?.closest<HTMLElement>('[data-equipment-slot]');
      const groundSlot = element?.closest<HTMLElement>('[data-ground-slot]');
      const targetItem = element?.closest<HTMLElement>('[data-item-kind][data-item-slot]');

      if (equipment) {
        const slotName = equipment.dataset.equipmentSlot;
        if (slotName) void equipDrop(slotName, session.payload);
      } else if (groundSlot && session.payload.source === 'grid') {
        const toSlot = Number(groundSlot.dataset.groundSlot);
        if (toSlot > 0) void gridToGround(session.payload, toSlot);
      } else if (targetItem && session.payload.source === 'grid') {
        const targetKind = targetItem.dataset.itemKind as GridName;
        const targetSlot = Number(targetItem.dataset.itemSlot);

        if (
          (targetKind === 'pockets' || targetKind === 'backpack' || targetKind === 'external' || targetKind === 'searched' || targetKind === 'searchedBackpack') &&
          targetSlot > 0 &&
          !(session.payload.kind === targetKind && session.payload.slot === targetSlot)
        ) {
          void mergeStack(session.payload, targetKind, targetSlot);
        }
      } else {
        const grids = Array.from(document.querySelectorAll<HTMLElement>('[data-grid-container]'));

        for (const grid of grids) {
          const rect = grid.getBoundingClientRect();

          if (
            event.clientX < rect.left ||
            event.clientX > rect.right ||
            event.clientY < rect.top ||
            event.clientY > rect.bottom
          ) continue;

          const cols = Number(grid.dataset.gridCols);
          const rows = Number(grid.dataset.gridRows);
          const kind = grid.dataset.gridContainer as GridName;

          if (!cols || !rows || (kind !== 'pockets' && kind !== 'backpack' && kind !== 'external' && kind !== 'searched' && kind !== 'searchedBackpack')) break;

          const cellWidth = rect.width / cols;
          const cellHeight = rect.height / rows;
          const x = Math.max(1, Math.min(cols, Math.floor((event.clientX - rect.left) / cellWidth) + 1));
          const y = Math.max(1, Math.min(rows, Math.floor((event.clientY - rect.top) / cellHeight) + 1));

          if (session.payload.source === 'ground') {
            void groundToGrid(session.payload, kind, x, y);
          } else {
            void dropOnGrid(session.payload, kind, x, y);
          }

          break;
        }
      }

      setDragging(null);
      setDragVisual(null);
    };

    window.addEventListener('pointermove', onMove);
    window.addEventListener('pointerup', onUp);

    return () => {
      window.removeEventListener('pointermove', onMove);
      window.removeEventListener('pointerup', onUp);
    };
  }, [dropOnGrid, equipDrop, gridToGround, groundToGrid, mergeStack]);

  useEffect(() => {
    const listener = (event: KeyboardEvent) => {
      if (!visible) return;

      if (event.key === 'Escape' && context) {
        event.preventDefault();
        setContext(null);
      }
    };

    window.addEventListener('keydown', listener);
    return () => window.removeEventListener('keydown', listener);
  }, [visible, context]);

  const stockExternalOpen = Boolean(
    rightInventory?.id &&
    rightInventory.type &&
    rightInventory.type !== 'newdrop' &&
    rightInventory.type !== 'drop' &&
    !state?.external &&
    !state?.searched
  );

  const gridProps = {
    selected,
    search,
    onSearch: setSearch,
    dragging,
    onSelect: setSelected,
    onUse: useItem,
    onQuickMove: quickMove,
    onPointerStart: startPointerDrag,
    onContext: openContext,
  };

  const equipmentPanel = state ? (
    <EquipmentRail
      state={state}
      dragging={dragging}
      onUnequip={unequip}
      onPointerStart={startPointerDrag}
      onContext={(event, entry, equipmentSlot) => openContext(event, entry, 'equipment', equipmentSlot)}
    />
  ) : null;

  const backpackPanel = state?.backpack ? (
    <Grid
      title={state.backpack.label || 'Backpack'}
      subtitle="Portable storage"
      inventory={state.backpack}
      kind="backpack"
      {...gridProps}
    />
  ) : null;

  const externalPanel = state?.external ? (
    <Grid
      title={state.external.label || 'Storage'}
      subtitle={
        state.external.type === 'trunk' ? 'Vehicle cargo' :
        state.external.type === 'glovebox' ? 'Vehicle glovebox' :
        state.external.type === 'policeevidence' ? 'Evidence storage' :
        state.external.type === 'dumpster' ? 'Container storage' :
        'External storage'
      }
      inventory={state.external}
      kind="external"
      {...gridProps}
    />
  ) : null;

  const groundPanel = state?.ground ? (
    <GroundPanel
      ground={state.ground}
      dragging={dragging}
      onPointerStart={startPointerDrag}
    />
  ) : null;

  if (!visible) return <InventoryHotbar />;

  return (
    <>
      <div className="avid-ui" onContextMenu={(event) => event.preventDefault()}>
        <header className="avid-top">
          <div className="avid-brand">
            <strong>AVID RP</strong>
            <small>MORE THAN A CITY</small>
          </div>

          <div className="avid-controls-hint">
            <span><kbd>ALT + CLICK</kbd> Quick move</span>
            <span><kbd>RMB</kbd> Item menu</span>
            <span><kbd>2×</kbd> Use</span>
          </div>

          <button aria-label="Close inventory" onClick={() => fetchNui('exit')}>×</button>
        </header>

        {!state ? (
          <div className="avid-loading">Loading Avid inventory…</div>
        ) : state.external ? (
          <div className="avid-layout avid-spatial-external">
            {equipmentPanel}

            <Grid
              title="Pockets"
              subtitle="What you are carrying right now."
              inventory={state.pockets}
              kind="pockets"
              {...gridProps}
            />

            <div className="avid-right">
              {externalPanel}
            </div>
          </div>
        ) : stockExternalOpen ? (
          <div className="avid-external-layout">
            {equipmentPanel}

            <section className="avid-panel avid-stock-transfer">
              <header className="avid-panel-head">
                <div>
                  <small>COMPATIBILITY VIEW</small>
                  <h2>{rightInventory.label || 'External Inventory'}</h2>
                  <p>Special inventory behavior is still handled by ox.</p>
                </div>
              </header>
              <div className="avid-stock-inner">
                <LeftInventory />
                <InventoryControl />
                <RightInventory />
              </div>
            </section>
          </div>
        ) : (
          <div className="avid-layout">
            {equipmentPanel}

            <Grid
              title="Pockets"
              subtitle="What you are carrying right now."
              inventory={state.pockets}
              kind="pockets"
              {...gridProps}
            />

            {(state.backpack || state.ground) && (
              <div className="avid-right">
                {backpackPanel}
                {groundPanel}
              </div>
            )}
          </div>
        )}

        <footer className="avid-footer">
          <span>LOS SANTOS, A DIFFERENT KIND OF LIFE</span>
          <span>PEOPLE › STORIES › A BETTER LOS SANTOS</span>
        </footer>

        {notice && <div className="avid-toast">{notice}</div>}

        {dragVisual && (
          <div
            className="avid-drag-ghost"
            style={{ left: dragVisual.x + 16, top: dragVisual.y + 16 }}
          >
            <img src={itemImage(dragVisual.item)} alt="" />
            <span>{dragVisual.item.label}</span>
          </div>
        )}

        <ContextMenu
          context={context}
          onClose={() => setContext(null)}
          onUse={() => {
            if (context) {
              void useItem(context.item, context.kind === 'equipment' ? undefined : context.kind);
            }
            setContext(null);
          }}
          onGive={() => {
            if (context) void giveSpecificItem(context.item, context.kind);
            setContext(null);
          }}
          onDrop={() => {
            if (context) void dropSpecificItem(context.item, context.kind);
          }}
          onQuickMove={() => {
            if (context && context.kind !== 'equipment') {
              void quickMove(context.item, context.kind);
            }
          }}
          onSplit={(amount) => {
            if (context && context.kind !== 'equipment') {
              void splitStack(context.item, context.kind, amount);
            }
          }}
          onEquip={(slot) => {
            if (context && context.kind !== 'equipment') {
              void equipItem(slot, context.item, context.kind);
            }
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
