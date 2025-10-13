export default {
  plugins: {
    "postcss-preset-mantine": {
      autoRem: true,
      mixins: {
        "safari-only": {
          "_::-webkit-full-page-media, _:future, :root &": {
            "@mixin-content": {},
          },
        },
      },
    },
    "postcss-simple-vars": {
      variables: {
        "mantine-breakpoint-xs": "36em",
        "mantine-breakpoint-sm": "48em",
        "mantine-breakpoint-md": "62em",
        "mantine-breakpoint-lg": "75em",
        "mantine-breakpoint-xl": "88em",
      },
    },
    autoprefixer: {},
  },
};
