import { type PageProps } from "@inertiajs/core";

import { type PageCSRF, type User } from ".";

export default interface SharedPageProps extends PageProps {
  csrf: PageCSRF;
  flash: {
    notice?: string;
    alert?: string;
  };
  currentUser: User | null;
}
