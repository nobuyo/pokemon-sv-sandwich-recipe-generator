# pokemon sv - sandwich recipe reverse resolution
# ref: https://hyperwiki.jp/pokemonsv/picnic/

require_relative 'recipe_generator'

g = RecipeGenerator.new
g.generate(
  [
    { type: :ice, power: :item_drop },
    { type: :steel, power: :capture },
    { type: :flying, power: :exp },
  ],
  max_ing: 2,
  max_spice: 2,
  exclude_mistica: true
)
