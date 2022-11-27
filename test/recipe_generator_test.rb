require 'csv'
require 'minitest/autorun'
require 'minitest/color'

require_relative '../recipe_generator'

module DynamicTestCase
  def add_tests
    build_powers = -> (names, include_lv: false) {
      translate_power_type = -> (name) {
        dict = {
          'タマゴパワー' => :egg,
          'ほかくパワー' => :capture,
          'けいけんちパワー' => :exp,
          'おとしものパワー' => :item_drop,
          'レイドパワー' => :raid,
          '二つ名パワー' => :title,
          'かがやきパワー' => :shiny,
          'でかでかパワー' => :humongous,
          'ちびちびパワー' => :teensy,
          'そうぐうパワー' => :encounter
        }
  
        dict[name]
      }

      translate_pokemon_type = -> (name) {
        dict = {
          'ノーマル' => :normal,
          'ほのお' => :fire,
          'みず' => :water,
          'でんき' => :electric,
          'くさ' => :grass,
          'じめん' => :ground,
          'いわ' => :rock,
          'かくとう' => :fighting,
          'ひこう' => :flying,
          'どく' => :poison,
          'エスパー' => :pshychic,
          'むし' => :bug,
          'あく' => :dark,
          'ゴースト' => :ghost,
          'はがね' => :steel,
          'ドラゴン' => :dragon,
          'フェアリー' => :fairy,
          'こおり' => :ice,
        }
  
        dict[name]
      }

      names.map do |name|
        power_type, value = name.split(':')

        if value
          pokemon_type, lv = value.split('Lv')
        else
          power_type, lv = power_type.split('Lv')
        end

        translated_power_type = translate_power_type.call(power_type)
        translated_pokemon_type = translate_pokemon_type.call(pokemon_type)

        a = {
          translated_power_type => translated_pokemon_type
        }
        a = a.merge({ "#{translated_power_type}_lv".to_sym => lv }) if include_lv

        a
      end.inject(&:merge)
    }

    test_cases_from_tsv = -> {
      tsv = CSV.read('sandwiches.tsv', col_sep: "\t", headers: false)

      tsv.map do |row|
        {
          name: row[0],
          ings: row[1].split(','),
          powers: build_powers.call(row[2].split(',')),
          powers_with_lv: build_powers.call(row[2].split(','), include_lv: true)
        }
      end
    }.call

    test_cases_from_tsv.each do |test|
      define_method "test_#{test[:name]}".to_sym do
        name = test[:name]
        recipe = @g.generate_by_name(test[:ings])

        if recipe.active_power != test[:powers]
          puts "\n#{name}"
          p test[:ings]
          p recipe.total_powers
          p recipe.total_tastes
          p recipe.total_type_value
          p recipe.active_power
          p test[:powers]
        end

        assert_equal(recipe.active_power, test[:powers])
      end
    end
  end
end

class RecipeGeneratorTest < Minitest::Test
  extend DynamicTestCase

  add_tests

  def setup
    @g = RecipeGenerator.new
  end
end
