import { Text } from "@mantine/core";
import { isEmail, isNotEmpty } from "@mantine/form";

import AppLayout from "~/components/AppLayout";
import { completeSignIn } from "~/helpers/authentication";
import { type User } from "~/types";

export interface LoginPageProps extends SharedPageProps {}

const LoginPage: PageComponent<LoginPageProps> = () => {
  // == Form
  const initialValues = {
    email: "",
    password: "",
    remember_me: true,
  };
  const { getInputProps, submit, submitting } = useForm<
    { user: User },
    typeof initialValues
  >({
    action: routes.usersSessions.create,
    descriptor: "sign in",
    validateInputOnBlur: true,
    initialValues,
    validate: {
      email: isEmail("email is invalid"),
      password: isNotEmpty("password is required"),
    },
    transformValues: values => ({
      user: values,
    }),
    onError: ({ setFieldValue }) => {
      setFieldValue("password", "");
    },
    onSuccess: ({ user }) => {
      completeSignIn(user);
    },
  });

  return (
    <Card withBorder>
      <Stack gap="sm">
        <Text ff="heading" fw={500} ta="center">
          sign in to <span style={{ fontWeight: 800 }}>{APP_NAME}</span>
        </Text>
        <form onSubmit={submit}>
          <Stack gap="xs">
            <TextInput
              {...getInputProps("email")}
              type="email"
              placeholder="email"
            />
            <TextInput
              {...getInputProps("password")}
              type="password"
              autoComplete="current-password"
              placeholder="password"
            />
            <Button
              type="submit"
              leftSection={<SignInIcon />}
              loading={submitting}
            >
              sign in
            </Button>
          </Stack>
        </form>
      </Stack>
    </Card>
  );
};

LoginPage.layout = page => (
  <AppLayout<LoginPageProps> title="sign in" withContainer containerSize={380}>
    {page}
  </AppLayout>
);

export default LoginPage;
