import { Button, Link, Text } from "~/components/email";
import EmailLayout from "~/components/EmailLayout";
import { type EmailComponent } from "~/helpers/inertia";
import { type User } from "~/types";

export interface UserEmailVerificationEmailProps {
  verificationUrl: string;
  user: User;
}

const UserVerificationEmail: EmailComponent<
  UserEmailVerificationEmailProps
> = ({ verificationUrl, user }) => {
  const { name } = user;
  return (
    <>
      <Text>hi, {name}!</Text>
      <Text>to continue, please click the button below:</Text>
      <Button href={verificationUrl}>confirm email address</Button>
      <Text style={{ marginTop: 14 }}>or, open this link in your browser:</Text>
      <Link
        className="link"
        href={verificationUrl}
        style={{ textTransform: "none" }}
      >
        {verificationUrl}
      </Link>
    </>
  );
};

UserVerificationEmail.layout = page => (
  <EmailLayout header="verify your email address">{page}</EmailLayout>
);

export default UserVerificationEmail;
