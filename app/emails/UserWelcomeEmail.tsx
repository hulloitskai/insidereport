import { Text } from "~/components/email";
import EmailLayout from "~/components/EmailLayout";
import { type EmailComponent } from "~/helpers/inertia";
import { type User } from "~/types";

export interface UserWelcomeEmailProps {
  user: User;
}

const UserWelcomeEmail: EmailComponent<UserWelcomeEmailProps> = ({ user }) => {
  const { name } = user;
  return (
    <>
      <Text>hi, {name}!</Text>
      <Text>thanks for signing up for {APP_NAME}!</Text>
    </>
  );
};

UserWelcomeEmail.layout = page => (
  <EmailLayout header={`welcome to ${APP_NAME}`}>{page}</EmailLayout>
);

export default UserWelcomeEmail;
