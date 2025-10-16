import { Text } from "@mantine/core";
import { isEmail, isNotEmpty } from "@mantine/form";

import AppLayout from "~/components/AppLayout";
import { type User } from "~/types";

export interface SignupPageProps extends SharedPageProps {}

const SignupPage: PageComponent<SignupPageProps> = () => {
  // == Form
  const initialValues = {
    name: "",
    email: "",
    password: "",
    password_confirmation: "",
  };
  const { getInputProps, submit, submitting } = useForm<
    { user: User },
    typeof initialValues
  >({
    action: routes.usersRegistrations.create,
    descriptor: "sign up",
    validateInputOnBlur: true,
    initialValues,
    validate: {
      email: isEmail("email is invalid"),
      password: isNotEmpty("password is required"),
      password_confirmation: (value, { password }) => {
        if (!value) {
          return "password confirmation is required";
        }
        if (value !== password) {
          return "password confirmation does not match password";
        }
      },
    },
    transformValues: values => ({ user: values }),
    onError: ({ setFieldValue }) => {
      setFieldValue("password", "");
      setFieldValue("password_confirmation", "");
    },
    onSuccess: () => {
      router.visit(routes.projects.new.path());
    },
  });

  return (
    <Card withBorder>
      <Stack gap="sm">
        <Text ff="heading" fw={500} ta="center">
          make your <span style={{ fontWeight: 800 }}>{APP_NAME}</span> account
        </Text>
        <form onSubmit={submit}>
          <Stack gap="xs">
            <TextInput
              {...getInputProps("name")}
              autoComplete="name"
              label="name"
              placeholder="your name"
            />
            <TextInput
              {...getInputProps("email")}
              type="email"
              label="email"
              placeholder="your email"
            />
            <TextInput
              {...getInputProps("password")}
              type="password"
              autoComplete="new-password"
              label="password"
              placeholder="new password"
            />
            <TextInput
              {...getInputProps("password_confirmation")}
              type="password"
              autoComplete="new-password"
              label="password (again)"
              placeholder="password (again)"
            />
            <Button
              type="submit"
              leftSection={<ContinueIcon />}
              loading={submitting}
            >
              sign up
            </Button>
          </Stack>
        </form>
      </Stack>
    </Card>
  );
};

SignupPage.layout = page => (
  <AppLayout<SignupPageProps> title="sign up" withContainer containerSize={380}>
    {page}
  </AppLayout>
);

export default SignupPage;
