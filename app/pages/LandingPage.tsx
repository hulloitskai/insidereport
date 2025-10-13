import { Text } from "@mantine/core";

import AppLayout from "~/components/AppLayout";

export interface LandingPageProps extends SharedPageProps {}

const LandingPage: PageComponent<LandingPageProps> = () => {
  return <Text>ur a fool harry</Text>;
};

LandingPage.layout = page => (
  <AppLayout<LandingPageProps> withContainer containerSize="sm">
    {page}
  </AppLayout>
);

export default LandingPage;
