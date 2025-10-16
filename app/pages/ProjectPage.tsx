import { Code, Spoiler, Text } from "@mantine/core";
import { type PropsWithChildren } from "react";

import AppLayout from "~/components/AppLayout";
import { type Project } from "~/types";

import classes from "./ProjectPage.module.css";

export interface ProjectPageProps extends SharedPageProps {
  project: Project;
}

const ProjectPage: PageComponent<ProjectPageProps> = ({ project }) => {
  return (
    <Stack gap="xl">
      <Box>
        <Badge>project</Badge>
        <Title fw={900}>{project.name}</Title>
      </Box>
      <Stack>
        {project.current_schema_snapshot ? (
          <>
            <Box>
              <Title order={5}>current schema</Title>
              <SectionSpoiler>
                <Code block>
                  {project.current_schema_snapshot.processed_schema}
                </Code>
              </SectionSpoiler>
            </Box>
            <Box>
              <Title order={5}>company analysis</Title>
              {project.current_schema_snapshot.company_analysis ? (
                <SectionSpoiler>
                  <Box
                    p="xs"
                    bg="gray.0"
                    style={{ borderRadius: "var(--mantine-radius-sm)" }}
                  >
                    <Text size="sm" style={{ whiteSpace: "pre-wrap" }}>
                      {project.current_schema_snapshot.company_analysis}
                    </Text>
                  </Box>
                </SectionSpoiler>
              ) : (
                <LoadingCompanyAnalysis />
              )}
            </Box>
          </>
        ) : (
          <Box>
            <Title order={5}>current schema</Title>
            <LoadingSchemaSnapshot />
          </Box>
        )}
      </Stack>
    </Stack>
  );
};

ProjectPage.layout = page => (
  <AppLayout<ProjectPageProps>
    title={({ project }) => project.name}
    withContainer
    containerSize="sm"
  >
    {page}
  </AppLayout>
);

export default ProjectPage;

const LoadingSchemaSnapshot: FC = () => {
  useEffect(() => {
    const interval = setInterval(() => {
      router.reload({
        only: ["project"],
      });
    }, 1000);
    return () => {
      clearInterval(interval);
    };
  }, []);

  return (
    <Box pos="relative">
      <Skeleton h={200} />
      <Center pos="absolute" inset={0}>
        <Text size="sm" c="dark">
          loading database schema... (this may take up to a minute)
        </Text>
      </Center>
    </Box>
  );
};

const LoadingCompanyAnalysis: FC = () => {
  useEffect(() => {
    const interval = setInterval(() => {
      router.reload({
        only: ["project"],
      });
    }, 1000);
    return () => {
      clearInterval(interval);
    };
  }, []);

  return (
    <Box pos="relative">
      <Skeleton h={200} />
      <Center pos="absolute" inset={0}>
        <Text size="sm" c="dark">
          analyzing company... (this may take a few minutes)
        </Text>
      </Center>
    </Box>
  );
};

const SectionSpoiler: FC<PropsWithChildren> = ({ children }) => {
  return (
    <Spoiler
      maxHeight={240}
      showLabel="show more"
      hideLabel="show less"
      className={classes.sectionSpoiler}
    >
      {children}
    </Spoiler>
  );
};
