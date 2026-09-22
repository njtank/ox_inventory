import React, { useContext } from 'react';
import { createPortal } from 'react-dom';
import { TransitionGroup } from 'react-transition-group';
import useNuiEvent from '../../hooks/useNuiEvent';
import useQueue from '../../hooks/useQueue';
import { Locale } from '../../store/locale';
import { getItemUrl } from '../../helpers';
import { SlotWithItem } from '../../typings';
import { Items } from '../../store/items';
import Fade from './transitions/Fade';

type ItemNotificationAction = 'added' | 'removed' | 'neutral';

interface ItemNotificationProps {
  item: SlotWithItem;
  text: string;
  count?: number;
  action: ItemNotificationAction;
}

export const ItemNotificationsContext = React.createContext<{
  add: (item: ItemNotificationProps) => void;
} | null>(null);

export const useItemNotifications = () => {
  const itemNotificationsContext = useContext(ItemNotificationsContext);
  if (!itemNotificationsContext) throw new Error('ItemNotificationsContext undefined');
  return itemNotificationsContext;
};

const ItemNotification = React.forwardRef(
  (props: { item: ItemNotificationProps; style?: React.CSSProperties }, ref: React.ForwardedRef<HTMLDivElement>) => {
    const slotItem = props.item.item;
    const label = slotItem.metadata?.label || Items[slotItem.name]?.label || slotItem.name;
    const count = props.item.count ?? slotItem.count ?? 1;

    return (
      <div
        className={'avid-item-notification is-' + props.item.action}
        style={props.style}
        ref={ref}
      >
        <div className="avid-item-notification-mark" />

        <div className="avid-item-notification-image">
          <img src={getItemUrl(slotItem)} alt="" />
          {count > 1 && <span>{count}x</span>}
        </div>

        <div className="avid-item-notification-copy">
          <small>{props.item.text}</small>
          <strong>{label}</strong>
        </div>
      </div>
    );
  }
);

export const ItemNotificationsProvider = ({ children }: { children: React.ReactNode }) => {
  const queue = useQueue<{
    id: number;
    item: ItemNotificationProps;
    ref: React.RefObject<HTMLDivElement | null>;
  }>();

  const add = (item: ItemNotificationProps) => {
    const ref = React.createRef<HTMLDivElement>();
    const notification = { id: Date.now() + Math.random(), item, ref };

    queue.add(notification);

    const timeout = setTimeout(() => {
      queue.remove();
      clearTimeout(timeout);
    }, 2300);
  };

  useNuiEvent<[item: SlotWithItem, text: string, count?: number]>('itemNotify', ([item, text, count]) => {
    const action: ItemNotificationAction =
      text === 'ui_added' ? 'added' :
      text === 'ui_removed' ? 'removed' :
      'neutral';

    add({
      item,
      text: Locale[text] || text,
      count,
      action,
    });
  });

  return (
    <ItemNotificationsContext.Provider value={{ add }}>
      {children}

      {createPortal(
        <TransitionGroup className="item-notification-container">
          {queue.values.map((notification) => (
            <Fade key={notification.id}>
              <ItemNotification item={notification.item} ref={notification.ref} />
            </Fade>
          ))}
        </TransitionGroup>,
        document.body
      )}
    </ItemNotificationsContext.Provider>
  );
};
