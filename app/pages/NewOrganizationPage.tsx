import { Text } from "@mantine/core";

import AppLayout from "~/components/AppLayout";

export interface NewOrganizationPageProps extends SharedPageProps {}

const NewOrganizationPage: PageComponent<NewOrganizationPageProps> = () => {
  return <Text>ur an organized fool harry</Text>;
};

NewOrganizationPage.layout = page => (
  <AppLayout<NewOrganizationPageProps> withContainer containerSize="xs">
    {page}
  </AppLayout>
);

export default NewOrganizationPage;
