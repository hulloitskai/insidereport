import { ModalsProvider } from "@mantine/modals";

import AmplitudeTracking from "./AmplitudeTracking";
import AppFlash from "./AppFlash";
import ClarityTracking from "./ClarityTracking";
import FullStoryTracking from "./FullStoryTracking";
import MiniProfilerPageTracking from "./MiniProfilerPageTracking";
import PageMeta from "./PageMeta";
import SentryTracking from "./SentryTracking";

import "@fontsource-variable/manrope";
import "@fontsource-variable/bricolage-grotesque";

import "@mantine/core/styles.layer.css";

const PageLayout: FC<PropsWithChildren> = ({ children }) => (
  <>
    <PageMeta />
    <ModalsProvider modalProps={{ size: "md" }}>{children}</ModalsProvider>
    <AppFlash />
    <SentryTracking />
    <FullStoryTracking />
    <ClarityTracking />
    <AmplitudeTracking />
    <MiniProfilerPageTracking />
  </>
);

export default PageLayout;
