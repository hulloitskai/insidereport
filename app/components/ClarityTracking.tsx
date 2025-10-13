// import Clarity from "@microsoft/clarity";

const ClarityTracking: FC = () => {
  const {
    component,
    // props: { currentFriend, currentUser },
  } = usePage();

  // == Current user tracking
  useEffect(() => {
    if (!("clarity" in window)) {
      return;
    }
    //   const { id, name } = currentUser;
    //   Clarity.identify(id, undefined, component, name);
    // }
  }, [component]);

  return null;
};

export default ClarityTracking;
