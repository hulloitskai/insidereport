import { resetSWRCache } from "~/helpers/routes/swr";
import { type User } from "~/types";

export const useCurrentUser = (): User | null => {
  const { currentUser } = usePageProps();
  return currentUser;
};

export const useAuthenticatedUser = (): User => {
  const currentUser = useCurrentUser();
  invariant(currentUser, "Missing authenticated user");
  return currentUser;
};

export const completeSignIn = (user: User): void => {
  void resetSWRCache();
  toast.success(<>welcome back, {user.name}</>, {
    icon: <span style={{ fontFamily: "var(--font-family-emoji)" }}>👋</span>,
  });
  router.visit(routes.home.redirect.path());
};

export const completeSignOut = (): void => {
  void resetSWRCache();
  router.visit(routes.landing.show.path());
  toast.success("you are now signed out");
};
