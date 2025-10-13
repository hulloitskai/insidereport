import { type InertiaLinkProps } from "@inertiajs/react";
import { Loader, type MenuItemProps, Text } from "@mantine/core";

import MenuIcon from "~icons/heroicons/bars-3-20-solid";
import ServerIcon from "~icons/heroicons/server-stack-20-solid";

import { completeSignOut } from "~/helpers/authentication";
import { useContact } from "~/helpers/contact";

import classes from "./AppMenu.module.css";

export interface AppMenuProps
  extends BoxProps,
    Omit<ComponentPropsWithoutRef<"div">, "style" | "children" | "onChange"> {}

const AppMenu: FC<AppMenuProps> = ({ ...otherProps }) => {
  const currentUser = useCurrentUser();
  const [opened, setOpened] = useState(false);

  // == Link items
  interface MenuLinkProps
    extends MenuItemProps,
      Omit<InertiaLinkProps, "color" | "style"> {}
  const MenuLink: FC<MenuLinkProps> = props => (
    <Menu.Item component={Link} {...props} />
  );

  return (
    <Menu
      position="bottom-end"
      trigger="click-hover"
      closeDelay={200}
      {...{ opened }}
      onChange={setOpened}
      offset={4}
      width={240}
      arrowPosition="center"
      className={classes.menu}
      {...otherProps}
    >
      <Menu.Target>
        <Badge
          className={classes.target}
          variant="default"
          size="lg"
          leftSection={<MenuIcon />}
        >
          menu
        </Badge>
      </Menu.Target>
      <Menu.Dropdown>
        {currentUser ? (
          <>
            <MenuLink
              href={routes.home.redirect.path()}
              leftSection={<HomeIcon />}
            >
              home
            </MenuLink>
            <LogoutItem
              onClose={() => {
                setOpened(false);
              }}
            />
          </>
        ) : (
          <>
            <Menu.Item
              leftSection={<SignInIcon />}
              component={Link}
              href={routes.usersSessions.new.path()}
            >
              sign in
            </Menu.Item>
            <MenuLink
              href={routes.usersRegistrations.new.path()}
              leftSection="🤩"
              className={classes.registrationItem}
            >
              sign up
            </MenuLink>
          </>
        )}
        <Menu.Divider />
        <ContactItem
          onClose={() => {
            setOpened(false);
          }}
        />
        <Menu.Divider />
        <ServerInfoItem />
      </Menu.Dropdown>
    </Menu>
  );
};

export default AppMenu;

interface LogoutItemProps extends BoxProps {
  onClose: () => void;
}

const LogoutItem: FC<LogoutItemProps> = ({ onClose, ...otherProps }) => {
  const { trigger, mutating } = useRouteMutation(routes.usersSessions.destroy, {
    descriptor: "sign out",
    onSuccess: () => {
      completeSignOut();
      onClose();
    },
  });

  return (
    <Menu.Item
      pos="relative"
      leftSection={mutating ? <Loader size={12} /> : <SignOutIcon />}
      closeMenuOnClick={false}
      onClick={() => {
        void trigger();
      }}
      {...otherProps}
    >
      sign out
    </Menu.Item>
  );
};

interface ContactItemProps extends BoxProps {
  onClose: () => void;
}

const ContactItem: FC<ContactItemProps> = ({ onClose, ...otherProps }) => {
  const [contact, { loading }] = useContact({
    subject: `re: ${APP_NAME}!`,
    onTriggered: onClose,
  });

  return (
    <Menu.Item
      leftSection={loading ? <Loader size={12} /> : <SendIcon />}
      closeMenuOnClick={false}
      onClick={() => {
        contact();
      }}
      {...otherProps}
    >
      contact the developer{" "}
      <span style={{ fontFamily: "var(--font-family-emoji)" }}>🧑‍💻</span>
    </Menu.Item>
  );
};

const ServerInfoItem: FC<BoxProps> = props => {
  const { data } = useRouteSWR<{ bootedAt: string }>(
    routes.healthcheckHealthchecks.check,
    {
      descriptor: "load server info",
    },
  );
  const { bootedAt } = data ?? {};

  return (
    <Menu.Item
      component="div"
      disabled
      className={classes.serverInfoItem}
      leftSection={<ServerIcon />}
      {...props}
    >
      server booted{" "}
      {bootedAt ? (
        <TimeAgo inherit>{bootedAt}</TimeAgo>
      ) : (
        <Skeleton
          display="inline-block"
          height="min-content"
          width="fit-content"
          lh={1}
          style={{ verticalAlign: "middle" }}
        >
          <Text span inherit inline display="inline-block">
            2 minutes ago
          </Text>
        </Skeleton>
      )}
    </Menu.Item>
  );
};
