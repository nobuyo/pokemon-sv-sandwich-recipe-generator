require_relative 'constant'

class Recipe
  attr_accessor :ingredients, :spices

  def initialize(ingredients:, spices:)
    @ingredients = ingredients
    @spices = spices
  end

  def inspect
    "#{@ingredients.map(&:name).join(', ')} + #{@spices.map(&:name).join(', ')} = #{active_power}"
  end

  def active_power
    powers = total_powers[0..2].map { |pw| pw[0] }
    _types = total_type_value[0..2].map { |v| v[0] }
    types = [_types[0], _types[2], _types[1]]

    powers.zip(types).map do |pw, ty|
      if pw == :egg
        [pw, nil]
      else
        [pw, ty]
      end
    end.to_h
  end

  def total_tastes
    tastes = TASTE_KEYS.map do |key|
      it = @ingredients.map { |i| i.tastes.dig(key) || 0 }.sum
      st = @spices.map { |i| i.tastes.dig(key) || 0 }.sum

      [key, it + st]
    end.to_h

    (@ingredients.map(&:name) + @spices.map(&:name)).combination(2).each do |pair|
      maybe_bonus = bonus_pairs[pair.sort]
      if maybe_bonus
        maybe_bonus.each do |key, value|
          tastes[key] += value
        end
      end
    end

    tastes.sort_by { |v| [1000000 - v[1], tastes_index(v[0])] }
  end

  def total_powers
    powers = POWER_KEYS.map do |key|
      ip = @ingredients.map { |i| i.powers.dig(key) || 0 }.sum
      sp = @spices.map { |i| i.powers.dig(key) || 0 }.sum

      [key, ip + sp]
    end.to_h

    tastes = total_tastes.map { _1[0] }
    case tastes[0..1]
    when [:sweet, :hot], [:hot, :sweet]
      powers[:raid] += 100
    when [:sweet, :sour], [:sour, :sweet]
      powers[:capture] += 100
    when [:bitter, :salty]
      powers[:exp] += 100
    else
      powers = add_bonus_by_taste(tastes[0], powers)
    end

    powers.sort { |a, b| b[1] <=> a[1] }
  end

  def add_bonus_by_taste(t, powers)
    case t
    when :salty
      powers[:encounter] += 100
    when :sour
      powers[:teensy] += 100
    when :sweet
      powers[:egg] += 100
    when :bitter
      powers[:item_drop] += 100
    when :hot
      powers[:humongous] += 100
    else
      raise 'unknown taste'
    end

    powers
  end

  def bonus_pairs
    {
      ["わぎりキウイ", "ハンバーグ"].sort => { sour: 50 },
      ["わぎりキウイ", "きりみフライ"].sort => { sour: 50 },
      ["わぎりキウイ", "やきチョリソー"].sort => { sour: 50 },
      ["わぎりキウイ", "やきベーコン"].sort => { sour: 50 },
      ["わぎりキウイ", "ハーブソーセージ"].sort => { sour: 50 },
      ["たまねぎスライス", "ハンバーグ"].sort => { hot: 50 },
      ["たまねぎスライス", "きりみフライ"].sort => { hot: 50 },
      ["たまねぎスライス", "やきチョリソー"].sort => { hot: 50 },
      ["たまねぎスライス", "やきベーコン"].sort => { hot: 50 },
      ["たまねぎスライス", "ハーブソーセージ"].sort => { hot: 50 },
      ["マーマレード", "ハンバーグ"].sort => { bitter: 50 },
      ["マーマレード", "きりみフライ"].sort => { bitter: 50 },
      ["マーマレード", "やきチョリソー"].sort => { bitter: 50 },
      ["マーマレード", "やきベーコン"].sort => { bitter: 50 },
      ["マーマレード", "ハーブソーセージ"].sort => { bitter: 50 },
      ["ペッパー", "ハンバーグ"].sort => { salty: 50 },
      ["ペッパー", "きりみフライ"].sort => { salty: 50 },
      ["ペッパー", "やきチョリソー"].sort => { salty: 50 },
      ["ペッパー", "やきベーコン"].sort => { salty: 50 },
      ["ペッパー", "ハーブソーセージ"].sort => { salty: 50 },
      ["バジル", "トマトスライス"].sort => { bitter: 50 },
      ["バジル", "カットミニトマト"].sort => { bitter: 50 },
      ["ケチャップ", "マスタード"].sort => { sour: 50 },
      ["キュウリスライス", "アボカド"].sort => { bitter: 50 },
      ["ヨーグルト", "バナナスライス"].sort => { sweet: 50 },
      ["ヨーグルト", "いちごスライス"].sort => { sweet: 50 },
      ["ヨーグルト", "わぎりリンゴ"].sort => { sweet: 50 },
      ["ヨーグルト", "わぎりキウイ"].sort => { sweet: 50 },
      ["ヨーグルト", "カットパイン"].sort => { sweet: 50 },
      ["スモークきりみ", "レタス"].sort => { salty: 50 },
      ["スモークきりみ", "トマトスライス"].sort => { salty: 50 },
      ["スモークきりみ", "カットミニトマト"].sort => { salty: 50 },
      ["スモークきりみ", "キュウリスライス"].sort => { salty: 50 },
      ["スモークきりみ", "ピクルススライス"].sort => { salty: 50 },
      ["スモークきりみ", "たまねぎスライス"].sort => { salty: 50 },
      ["スモークきりみ", "アーリーレッド"].sort => { salty: 50 },
      ["スモークきりみ", "ピーマンスライス"].sort => { salty: 50 },
      ["スモークきりみ", "あかパプリカスライス"].sort => { salty: 50 },
      ["スモークきりみ", "きパプリカスライス"].sort => { salty: 50 },
      ["スモークきりみ", "アボカド"].sort => { salty: 50 },
    }
  end

  def total_type_value
    values = TYPE_KEYS.map do |key|
      iv = @ingredients.map { |i| i.type_values.dig(key) || 0 }.sum
      sv = @spices.map { |i| i.type_values.dig(key) || 0 }.sum

      [key, iv + sv]
    end

    values.sort_by { |v| [100000 - v[1], pokemon_type_index(v[0])] }
  end

  def tastes_index(e)
    [:sweet, :salty, :sour, :bitter, :hot].index(e)
  end

  def pokemon_type_index(e)
    [
      :normal,
      :fighting,
      :flying,
      :poison,
      :ground,
      :rock,
      :bug,
      :ghost,
      :steel,
      :fire,
      :water,
      :grass,
      :electric,
      :pshychic,
      :ice,
      :dragon,
      :dark,
      :fairy,
    ].index(e)
  end
end

class Ingredient
  attr_accessor :name, :type_values, :powers, :tastes

  def initialize(name:, powers:, type_values:, tastes:)
    @name = name
    @powers = powers
    @type_values = type_values
    @tastes = tastes

    validate_keys
  end

  def effective?(power, type)
    type_values.key?(type) && powers.key?(power) && powers[power] > 0
  end

  private

  def validate_keys
    powers.keys.each do |key|
      unless POWER_KEYS.include?(key)
        puts "ERROR: The type for power \"#{key}\" is not defined."
        exit 1
      end
    end
    type_values.keys.each do |key|
      unless TYPE_KEYS.include?(key)
        puts "The type for pokemon \"#{key}\" is not defined."
        exit 1
      end
    end
    tastes.keys.each do |key|
      unless TASTE_KEYS.include?(key)
        puts "The type for taste \"#{key}\" is not defined."
        exit 1
      end
    end
  end
end

class Spice < Ingredient; end

class RecipeGenerator
  MAX_INGREDIENTS = 6
  MAX_SPICES = 4

  PARAM_ING_A = {
    capture: 4,
    egg: -4,
    encounter: 7,
    exp: 0,
    humongous: 0,
    item_drop: 0,
    raid: -1,
    shiny: 0,
    teensy: 0,
    title: 0,
  }
  PARAM_ING_B = {
    capture: 12,
    egg: 0,
    encounter: 21,
    exp: 0,
    humongous: 0,
    item_drop: 0,
    raid: -3,
    shiny: 0,
    teensy: 0,
    title: 0,
  }
  PARAM_ING_C = {
    capture: 0,
    egg: 0,
    encounter: 4,
    exp: 7,
    humongous: 0,
    item_drop: -1,
    raid: 0,
    shiny: 0,
    teensy: 0,
    title: 0,
  }
  PARAM_ING_D = {
    capture: 21,
    egg: 0,
    encounter: -3,
    exp: 0,
    humongous: 0,
    item_drop: 0,
    raid: 12,
    shiny: 0,
    teensy: 0,
    title: 0,
  }
  PARAM_ING_E = {
    capture: 0,
    egg: 0,
    encounter: 12,
    exp: 0,
    humongous: 12,
    item_drop: 0,
    raid: 0,
    shiny: 0,
    teensy: -3,
    title: 0,
  }
  PARAM_ING_F = {
    capture: -1,
    egg: 4,
    encounter: 0,
    exp: 0,
    humongous: -5,
    item_drop: 7,
    raid: 0,
    shiny: 0,
    teensy: 0,
    title: 0,
  }
  PARAM_ING_G = {
    capture: 2,
    egg: 0,
    encounter: -2,
    exp: 2,
    humongous: 0,
    item_drop: 0,
    raid: 0,
    shiny: 0,
    teensy: 0,
    title: 0,
  }
  PARAM_ING_H = {
    capture: 0,
    egg: 2,
    encounter: -2,
    exp: 0,
    humongous: 0,
    item_drop: 0,
    raid: 2,
    shiny: 0,
    teensy: 0,
    title: 0,
  }

  PARAM_SPICE_A = {
    capture: 0,
    egg: 5,
    encounter: 0,
    exp: -3,
    humongous: 0,
    item_drop: 12,
    raid: 0,
    shiny: 0,
    teensy: -15,
    title: 0,
  }
  PARAM_SPICE_B = {
    capture: 0,
    egg: -3,
    encounter: 2,
    exp: 10,
    humongous: 0,
    item_drop: 0,
    raid: 14,
    shiny: 0,
    teensy: 0,
    title: 0,
  }
  PARAM_SPICE_C = {
    capture: 0,
    egg: 0,
    encounter: 12,
    exp: 0,
    humongous: -3,
    item_drop: 0,
    raid: 0,
    shiny: 0,
    teensy: 0,
    title: 0,
  }
  PARAM_SPICE_D = {
    capture: 0,
    egg: 0,
    encounter: 0,
    exp: 0,
    humongous: 0,
    item_drop: 0,
    raid: 0,
    shiny: 0,
    teensy: 0,
    title: 1000,
  }

  INGS = [
    # Group A
    Ingredient.new(name: 'レタス', tastes: { bitter: 2, sweet: 1 }, powers: PARAM_ING_A, type_values: { grass: 6 }),
    Ingredient.new(name: 'トマトスライス', tastes: { bitter: 2, sour: 4, sweet: 2 }, powers: PARAM_ING_A, type_values: { fairy: 6 }),
    Ingredient.new(name: 'カットミニトマト', tastes: { bitter: 1, sour: 5, sweet: 3 }, powers: PARAM_ING_A, type_values: { bug: 6 }),
    Ingredient.new(name: 'キュウリスライス', tastes: { bitter: 1, sour: 1 }, powers: PARAM_ING_A, type_values: { water: 6 }),
    Ingredient.new(name: 'ピクルススライス', tastes: { bitter: 2, sour: 4, sweet: 1 }, powers: PARAM_ING_A, type_values: { fighting: 6 }),
    Ingredient.new(name: 'たまねぎスライス', tastes: { bitter: 1, hot: 3, sweet: 2 }, powers: PARAM_ING_A, type_values: { pshychic: 6 }),
    Ingredient.new(name: 'アーリーレッド', tastes: { bitter: 1, sweet: 3 }, powers: PARAM_ING_A, type_values: { ghost: 6 }),
    Ingredient.new(name: 'ピーマンスライス', tastes: { bitter: 5, sour: 1, sweet: 1 }, powers: PARAM_ING_A, type_values: { poison: 6 }),
    Ingredient.new(name: 'あかパプリカスライス', tastes: { bitter: 3, sour: 1, sweet: 1 }, powers: PARAM_ING_A, type_values: { fire: 6 }),
    Ingredient.new(name: 'きパプリカスライス', tastes: { bitter: 3, sour: 1, sweet: 1 }, powers: PARAM_ING_A, type_values: { electric: 6 }),
    Ingredient.new(name: 'アボカド', tastes: { sour: 1, sweet: 3 }, powers: PARAM_ING_A, type_values: { dragon: 6 }),
    Ingredient.new(name: 'ハムスライス', tastes: { salty: 5, sweet: 1 }, powers: PARAM_ING_A, type_values: { ground: 6 }),
    Ingredient.new(name: 'やきベーコン', tastes: { bitter: 4, salty: 5, sour: 1, sweet: 1 }, powers: PARAM_ING_A, type_values: { rock: 6 }),
    Ingredient.new(name: 'なまハム', tastes: { salty: 4, sour: 1, sweet: 2 }, powers: PARAM_ING_A, type_values: { flying: 6 }),
    Ingredient.new(name: 'ガケガニスティック', tastes: { salty: 4, sweet: 4 }, powers: PARAM_ING_A, type_values: { ice: 6 }),
    Ingredient.new(name: 'スモークきりみ', tastes: { bitter: 3, salty: 3, sour: 2, sweet: 1 }, powers: PARAM_ING_A, type_values: { dark: 6 }),
    Ingredient.new(name: 'トーフ', tastes: { bitter: 3, hot: 1, salty: 4, sour: 1, sweet: 3 }, powers: PARAM_ING_A, type_values: { normal: 6 }),

    # Group B
    Ingredient.new(name: 'ハンバーグ', tastes: { bitter: 9, salty: 12, sweet: 6 }, powers: PARAM_ING_B, type_values: { steel: 18 }),

    # Group C
    Ingredient.new(name: 'やきチョリソー', tastes: { bitter: 2, hot: 4, salty: 4 }, powers: PARAM_ING_C, type_values: { normal: 12, poison: 12, bug: 12, fire: 12, electric: 12, dragon: 12 }),
    Ingredient.new(name: 'ハーブソーセージ', tastes: { bitter: 4, salty: 4, sweet: 1 }, powers: PARAM_ING_C, type_values: { ground: 12, fighting: 12, ghost: 12, pshychic: 12, water: 12, dark: 12 }),
    Ingredient.new(name: 'スライスエッグ', tastes: { bitter: 1, salty: 2, sweet: 1 }, powers: PARAM_ING_C, type_values: { flying: 12, rock: 12, steel: 12, grass: 12, ice: 12, fairy: 12 }),

    # Group D
    Ingredient.new(name: 'きりみフライ', tastes: { bitter: 3, salty: 3, sweet: 2 }, powers: PARAM_ING_D, type_values: { normal: 20, flying: 20, ground: 20, bug: 20, steel:20, water: 20, electric: 20, ice: 20, dark: 20 }),
    Ingredient.new(name: 'トルティージャ', tastes: { bitter: 3, hot: 1, salty: 4, sour: 1, sweet: 3 }, powers: PARAM_ING_D, type_values: { fighting: 20, poison: 20, rock: 20, ghost: 20, fire:20, grass: 20, pshychic: 20, dragon: 20, fairy: 20 }),

    # Group E
    Ingredient.new(name: 'ヌードル', tastes: { salty: 4 }, powers: PARAM_ING_E, type_values: { poison: 30, rock: 30, ground: 30, electric: 30, pshychic: 30, ice: 30 }),
    Ingredient.new(name: 'ポテトサラダ', tastes: { bitter: 1, salty: 3, sour: 4, sweet: 2 }, powers: PARAM_ING_E, type_values: { bug: 30, ghost: 30, steel: 30, dragon: 30, dark: 30, fairy: 30 }),
    Ingredient.new(name: 'ライス', tastes: { sour: 1, sweet: 3 }, powers: PARAM_ING_E, type_values: { normal: 30, fighting: 30, flying: 30, fire: 30, water: 30, grass: 30 }),

    # Group F
    Ingredient.new(name: 'ハラペーニョ', tastes: { hot: 5, sour: 2 }, powers: PARAM_ING_F, type_values: { rock: 7, grass: 7, fairy: 7 }),
    Ingredient.new(name: 'カットパイン', tastes: { bitter: 1, sour: 5, sweet: 3 }, powers: PARAM_ING_F, type_values: { water: 7, dark: 7, ground: 7 }),
    Ingredient.new(name: 'わぎりリンゴ', tastes: { bitter: 1, sour: 3, sweet: 4 }, powers: PARAM_ING_F, type_values: { flying: 7, steel: 7, ice: 7 }),
    Ingredient.new(name: 'わぎりキウイ', tastes: { bitter: 1, sour: 5, sweet: 2 }, powers: PARAM_ING_F, type_values: { poison: 7, fire: 7, dragon: 7 }),
    Ingredient.new(name: 'いちごスライス', tastes: { sour: 4, sweet: 4 }, powers: PARAM_ING_F, type_values: { fighting: 7, ghost: 7, pshychic: 7 }),
    Ingredient.new(name: 'バナナスライス', tastes: { sour: 1, sweet: 4 }, powers: PARAM_ING_F, type_values: { normal: 7, bug: 7, electric: 7 }),

    # Group G
    Ingredient.new(name: 'スライスチーズ', tastes: { salty: 3, sweet: 1 }, powers: PARAM_ING_G, type_values: { normal: 5, fighting: 5, flying: 5, poison: 5, ground: 5, rock: 5, bug: 5, ghost: 5, steel:5, dragon: 5, fire: 5, water: 5, grass: 5, pshychic: 5, fairy: 5, electric: 5, ice: 5, dark: 5 }),

    # Group H
    Ingredient.new(name: 'バジル', tastes: { bitter: 4, salty: 1, sour: 1 }, powers: PARAM_ING_H, type_values: { water: 1, grass: 1, dark: 1, pshychic: 1, fire: 1, electric: 1, dragon: 1, fairy: 1, ice: 1 }),
    Ingredient.new(name: 'クレソン', tastes: { bitter: 5, hot: 1, salty: 1, sour: 2 }, powers: PARAM_ING_H, type_values: { normal: 1, fighting: 1, flying: 1, poison: 1, ground: 1, rock: 1, bug: 1, ghost: 1, steel: 1 }),
  ]

  SPICES = [
    Spice.new(name: 'ベリージャム', tastes: { salty: 4, sour: 16, sweet: 16 }, powers: PARAM_SPICE_A, type_values: { electric: 4, ice: 4, dark: 4 }),
    Spice.new(name: 'ビネガー', tastes: { bitter: 4, sour: 20, sweet: 4 }, powers: PARAM_SPICE_A, type_values: { pshychic: 4, dragon: 4, fairy: 4 }),
    Spice.new(name: 'ホイップクリーム', tastes: { sweet: 20 }, powers: PARAM_SPICE_A, type_values: { normal: 4, flying: 4, ground: 4 }),
    Spice.new(name: 'クリームチーズ', tastes: { salty: 12, sour: 12, sweet: 12 }, powers: PARAM_SPICE_A, type_values: { bug: 4, steel: 4, water: 4 }),
    Spice.new(name: 'マーマレード', tastes: { bitter: 18, salty: 4, sour: 16, sweet: 12 }, powers: PARAM_SPICE_A, type_values: { fighting: 4, poison: 4, rock: 4 }),
    Spice.new(name: 'オリーブオイル', tastes: { bitter: 4, sour: 4 }, powers: PARAM_SPICE_A, type_values: { ghost: 4, fire: 4, grass: 4 }),

    Spice.new(name: 'マヨネーズ', tastes: { salty: 8, sour: 20 }, powers: PARAM_SPICE_B, type_values: { normal: 2, fighting: 2 }),
    Spice.new(name: 'ケチャップ', tastes: { salty: 16, sour: 16, sweet: 8 }, powers: PARAM_SPICE_B, type_values: { flying: 2, poison: 2 }),
    Spice.new(name: 'バター', tastes: { salty: 12, sweet: 23 }, powers: PARAM_SPICE_B, type_values: { bug: 2, ghost: 2 }),
    Spice.new(name: 'チリソース', tastes: { hot: 20, salty: 12, sour: 8, sweet: 8 }, powers: PARAM_SPICE_B, type_values: { water: 2, grass: 2 }),
    Spice.new(name: 'マスタード', tastes: { bitter: 8, hot: 16, salty: 8, sour: 8, sweet: 4 }, powers: PARAM_SPICE_B, type_values: { ground: 2, rock: 2 }),
    Spice.new(name: 'ピーナッツバター', tastes: { salty: 12, sweet: 16 }, powers: PARAM_SPICE_B, type_values: { steel: 2, fire: 2 }),
    Spice.new(name: 'ペッパー', tastes: { bitter: 8, hot: 16, salty: 4 }, powers: PARAM_SPICE_B, type_values: { ice: 2, dragon: 2 }),
    Spice.new(name: 'ソルト', tastes: { bitter: 4, salty: 20 }, powers: PARAM_SPICE_B, type_values: { electric: 2, pshychic: 2 }),
    Spice.new(name: 'ヨーグルト', tastes: { sour: 16, sweet: 16 }, powers: PARAM_SPICE_B, type_values: { dark: 2, fairy: 2 }),

    Spice.new(name: 'ワサビソース', tastes: { hot: 20, salty: 4, sweet: 4 }, powers: PARAM_SPICE_C, type_values: { electric: 2, pshychic: 2, ice: 2, dragon: 2, dark: 2, fairy: 2 }),
    Spice.new(name: 'カレーパウダー', tastes: { bitter: 12, hot: 30, salty: 4, sour: 4, sweet: 4 }, powers: PARAM_SPICE_C, type_values: { bug: 2, ghost: 2, steel: 2, fire: 2, water: 2, grass: 2 }),
    Spice.new(name: 'ホースラディッシュ', tastes: { hot: 16, sweet: 4 }, powers: PARAM_SPICE_C, type_values: { normal: 2, fighting: 2, flying: 2, poison: 2, ground: 2, rock: 2 }),
  ]

  MISTICA_SPICES = [
    Spice.new(name: 'ひでん：にがスパイス', tastes: { bitter: 500 }, powers: PARAM_SPICE_D, type_values: { normal: 250, fighting: 250, flying: 250, poison: 250, ground: 250, rock: 250, bug: 250, ghost: 250, steel:250, dragon: 250, fire: 250, water: 250, grass: 250, pshychic: 250, fairy: 250, electric: 250, ice: 250, dark: 250 }),
    Spice.new(name: 'ひでん：からスパイス', tastes: { hot: 500 }, powers: PARAM_SPICE_D, type_values: { normal: 250, fighting: 250, flying: 250, poison: 250, ground: 250, rock: 250, bug: 250, ghost: 250, steel:250, dragon: 250, fire: 250, water: 250, grass: 250, pshychic: 250, fairy: 250, electric: 250, ice: 250, dark: 250 }),
    Spice.new(name: 'ひでん：しおスパイス', tastes: { salty: 500 }, powers: PARAM_SPICE_D, type_values: { normal: 250, fighting: 250, flying: 250, poison: 250, ground: 250, rock: 250, bug: 250, ghost: 250, steel:250, dragon: 250, fire: 250, water: 250, grass: 250, pshychic: 250, fairy: 250, electric: 250, ice: 250, dark: 250 }),
    Spice.new(name: 'ひでん：すぱスパイス', tastes: { sour: 500 }, powers: PARAM_SPICE_D, type_values: { normal: 250, fighting: 250, flying: 250, poison: 250, ground: 250, rock: 250, bug: 250, ghost: 250, steel:250, dragon: 250, fire: 250, water: 250, grass: 250, pshychic: 250, fairy: 250, electric: 250, ice: 250, dark: 250 }),
    Spice.new(name: 'ひでん：あまスパイス', tastes: { sweet: 500 }, powers: PARAM_SPICE_D, type_values: { normal: 250, fighting: 250, flying: 250, poison: 250, ground: 250, rock: 250, bug: 250, ghost: 250, steel:250, dragon: 250, fire: 250, water: 250, grass: 250, pshychic: 250, fairy: 250, electric: 250, ice: 250, dark: 250 }),
  ]

  def generate(conds, min_ing: 1, max_ing: MAX_INGREDIENTS, min_spice: 1, max_spice: MAX_SPICES, exclude_mistica: false)
    validate_conditions(conds)

    c = conds.shift
    answers = base_answer_group(c, min_ing: min_ing, max_ing: max_ing, min_spice: min_spice, max_spice: max_spice, exclude_mistica: exclude_mistica)

    answers.each do |r|
      puts r.inspect
    end

    conds.each do |c|
      type = c[:type]
      power = c[:power]

      answers = answers.filter { |r| r.active_power.dig(power) == type }
    end

    answers.each do |r|
      puts r.inspect
    end

    answers
  end

  def generate_by_name(names)
    ings = names.map { |n| instantize_ingredient_by_name(n) }
    ings, spices = ings.partition { |i| i.class.name == 'Spice' }

    Recipe.new(ingredients: ings, spices: spices)
  end

  private

  def instantize_ingredient_by_name(name)
    INGS.find { |i| i.name == name } || SPICES.find { |i| i.name == name } || MISTICA_SPICES.find { |i| i.name == name }
  end

  def validate_conditions(conds)
    unless conds.length <= 3
      puts color("ERROR: Too many power conditions. The maximum number of condition you can specify is 3.", :red)
      exit 1
    end

    conds.each do |c|
      unless POWER_KEYS.include?(c[:power])
        puts color("ERROR: The type for power \"#{c[:power]}\" is not defined.", :red)
        exit 1
      end

      unless TYPE_KEYS.include?(c[:type])
        puts color("ERROR: The type for pokemon \"#{c[:type]}\" is not defined.", :red)
        exit 1
      end
    end
  end

  def color(str, color)
    case color
    when :red
      "\e[31m#{str}\e[0m"
    when :green
      "\e[32m#{str}\e[0m"
    end
  end

  def base_answer_group(c, min_ing:, max_ing:, min_spice:, max_spice:, exclude_mistica:)
    type = c[:type]
    power = c[:power]

    print color('Building combinations... ', :green)

    ing_range = (min_ing..max_ing)
    spice_range = (min_spice..max_spice)

    base_ing_combinations = ing_range.map { |n| INGS.repeated_combination(n) }.inject(&:+).to_a
    ing_combinations_include_effective, ing_combinations_non_include_effective = base_ing_combinations.partition { |ic| ic.to_a.any? { |i| i.effective?(power, type) } }

    base_spice_combinations = spice_range.map { |n|
      if exclude_mistica
        SPICES.repeated_combination(n)
      else
        (SPICES + MISTICA_SPICES).repeated_combination(n)
      end
    }.inject(&:+).to_a
    spice_combinations_include_effective, spice_combinations_non_include_effective = base_spice_combinations.partition { |ic| ic.to_a.any? { |i| i.effective?(power, type) } }

    all_counts = [
      ing_combinations_include_effective.count * spice_combinations_include_effective.count,
      ing_combinations_include_effective.count * spice_combinations_non_include_effective.count,
      ing_combinations_non_include_effective.count * spice_combinations_include_effective.count,
    ].sum

    puts color("Found #{all_counts} combinations.", :green)
    puts color('Searching recipe...', :green)
    recipes = []

    ing_combinations_include_effective.each do |ic|
      spice_combinations_include_effective.each do |sc|
        recipes << Recipe.new(ingredients: ic.to_a, spices: sc.to_a)
      end
    end

    ing_combinations_include_effective.each do |ic|
      spice_combinations_non_include_effective.each do |sc|
        recipes << Recipe.new(ingredients: ic.to_a, spices: sc.to_a)
      end
    end

    ing_combinations_non_include_effective.each do |ic|
      spice_combinations_include_effective.each do |sc|
        recipes << Recipe.new(ingredients: ic.to_a, spices: sc.to_a)
      end
    end

    recipes.filter { |r| r.active_power.dig(power) == type }
  end
end
