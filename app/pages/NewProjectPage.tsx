import { Text } from "@mantine/core";
import { isNotEmpty } from "@mantine/form";

import AppLayout from "~/components/AppLayout";
// import ImageInput from "~/components/ImageInput";
import { type Project } from "~/types";

export interface NewProjectPageProps extends SharedPageProps {}

const NewProjectPage: PageComponent<NewProjectPageProps> = () => {
  // == Form
  const initialValues = {
    name: "",
    database_url: "",
    // display_photo: null as Upload | null,
  };
  const { getInputProps, submit, submitting } = useForm<
    { project: Project },
    typeof initialValues
  >({
    action: routes.projects.create,
    descriptor: "create project",
    validateInputOnBlur: true,
    initialValues,
    validate: {
      name: isNotEmpty("name is required"),
      database_url: isNotEmpty("database connection URL is required"),
    },
    transformValues: values => ({ project: values }),
    onSuccess: ({ project }) => {
      router.visit(routes.projects.show.path({ id: project.id }));
    },
  });

  return (
    <Card withBorder>
      <Stack gap="sm">
        <Text ff="heading" fw={600} ta="center">
          new project
        </Text>
        <form onSubmit={submit}>
          <Stack gap="xs">
            <TextInput
              {...getInputProps("name")}
              label="name"
              required
              placeholder="my project"
            />
            <TextInput
              {...getInputProps("database_url")}
              label="database connection URL"
              required
              placeholder="postgres://dbuser:dbpass@db.supabase.co:5432/postgres"
              styles={{
                input: {
                  fontFamily: "var(--mantine-font-family-monospace)",
                  fontSize: "var(--mantine-font-size-sm)",
                },
              }}
            />
            {/* <ImageInput
              {...getInputProps("display_photo")}
              label="display photo (optional)"
              cropToAspect={1}
              center
              w={140}
            /> */}
            <Button
              type="submit"
              leftSection={<ContinueIcon />}
              loading={submitting}
            >
              create project
            </Button>
          </Stack>
        </form>
      </Stack>
    </Card>
  );
};

NewProjectPage.layout = page => (
  <AppLayout<NewProjectPageProps>
    title="new project"
    withContainer
    containerSize="xs"
  >
    {page}
  </AppLayout>
);

export default NewProjectPage;
