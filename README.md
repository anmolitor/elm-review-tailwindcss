# elm-review-tailwindcss

Provides [`elm-review`](https://package.elm-lang.org/packages/jfmengels/elm-review/latest/) rules to use when you primarily use TailwindCSS to style your Elm application.

## Provided rules

- [`TailwindCss.NoCssConflict`](https://package.elm-lang.org/packages/anmolitor/elm-review-tailwindcss/1.0.0/TailwindCss-NoCssConflict) - Reports REPLACEME.
- [`TailwindCss.NoUnknownClasses`](https://package.elm-lang.org/packages/anmolitor/elm-review-tailwindcss/1.0.0/TailwindCss-NoUnknownClasses) - Reports if classes are used that are not known at compile-time.
- [`TailwindCss.ConsistentClassOrder`](https://package.elm-lang.org/packages/anmolitor/elm-review-tailwindcss/1.0.0/TailwindCss-ConsistentClassOrder) - Reports if classes are not ordered according to the TailwindCSS recommendations.

## Configuration

```elm
module ReviewConfig exposing (config)

import Review.Rule exposing (Rule)
import TailwindCss.ConsistentClassOrder
import TailwindCss.NoCssConflict
import TailwindCss.NoUnknownClasses
-- Note that this module is not provided! You have to generate the module yourself using postcss and our postcss-plugin.
import TailwindCss.ClassOrder exposing (classOrder)

config : List Rule
config =
    [ TailwindCss.ConsistentClassOrder.rule (TailwindCss.ConsistentClassOrder.defaultConfig classOrder)
    , TailwindCss.NoCssConflict.rule
    , TailwindCss.NoUnknownClasses.rule (TailwindCss.NoUnknownClasses.defaultConfig classOrder)
    ]
```

## Try it out

You can try the example configuration above out by running the following command:

```bash
elm-review --template anmolitor/elm-review-tailwindcss/example
```
