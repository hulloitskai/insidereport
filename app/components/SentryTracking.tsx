// import { isInitialized, setUser, type User } from "@sentry/react";

const SentryTracking: FC = () => {
  // == Current user tracking
  // useEffect(() => {
  //   if (isInitialized()) {
  //     if (currentFriend) {
  //       const { id } = currentFriend;
  //       const user: User = { id, name: prettyFriendName(currentFriend) };
  //       setUser(user);
  //       console.info("Set Sentry user", user);
  //     } else if (currentUser) {
  //       const { id, handle, name } = currentUser;
  //       const user: User = { id, username: handle, name };
  //       setUser(user);
  //       console.info("Set Sentry user", user);
  //     } else {
  //       setUser(null);
  //     }
  //   }
  //   // eslint-disable-next-line react-hooks/exhaustive-deps
  // }, [currentFriend?.id, currentUser?.id]);

  return null;
};

export default SentryTracking;
