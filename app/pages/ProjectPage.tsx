import { JsonInput, Spoiler, Text } from "@mantine/core";

import AppLayout from "~/components/AppLayout";
import { type Project } from "~/types";

import classes from "./ProjectPage.module.css";

export interface ProjectPageProps extends SharedPageProps {
  project: Project;
}

const ProjectPage: PageComponent<ProjectPageProps> = ({ project }) => {
  return (
    <Stack gap="xs">
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
                <JsonInput
                  autosize
                  value={JSON.stringify(
                    project.current_schema_snapshot.processed_schema,
                    null,
                    2,
                  )}
                  styles={{
                    input: {
                      fontSize: "var(--mantine-font-size-xs)",
                    },
                  }}
                />
              </SectionSpoiler>
            </Box>
            <Box>
              <Title order={5}>company analysis</Title>
              {project.current_schema_snapshot.company_analysis ? (
                <SectionSpoiler>
                  <Text size="sm" style={{ whiteSpace: "pre-wrap" }}>
                    {project.current_schema_snapshot.company_analysis}
                  </Text>
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
        {!isEmpty(project.reporters) && (
          <Box>
            <Title order={5}>reporters</Title>
            <Stack gap="xs">
              {project.reporters.map(reporter => (
                <Card key={reporter.id} withBorder>
                  <Stack gap={8}>
                    <Group justify="space-between">
                      <Text ff="heading" fw={600}>
                        {reporter.name}
                      </Text>
                      <Badge>{reporter.role}</Badge>
                    </Group>
                    <Box>
                      <Text ff="heading" fw={500} size="sm">
                        personality
                      </Text>
                      <Text size="sm" style={{ whiteSpace: "pre-wrap" }}>
                        {reporter.personality}
                      </Text>
                    </Box>
                    <Box>
                      <Text ff="heading" fw={500} size="sm">
                        journalistic approach
                      </Text>
                      <Text size="sm" style={{ whiteSpace: "pre-wrap" }}>
                        {reporter.journalistic_approach}
                      </Text>
                    </Box>
                  </Stack>
                </Card>
              ))}
            </Stack>
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
    }, 2000);
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

const SectionSpoiler: FC<PropsWithChildren> = ({ children }) => (
  <Spoiler
    maxHeight={240}
    showLabel="show more"
    hideLabel="show less"
    className={classes.sectionSpoiler}
  >
    {children}
  </Spoiler>
);
