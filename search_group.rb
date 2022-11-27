require 'csv'

spices = [                                                        
    "ベリージャム",                                                            
    "ホイップクリーム",                                                        
    "クリームチーズ",                                                          
    "マーマレード",                                                            
    "ピーナッツバター",                                                        
    "ヨーグルト",                                                              
    "ひでん：にがスパイス",                                                    
    "ひでん：からスパイス",                                                    
    "ひでん：しおスパイス",                                                    
    "ひでん：すぱスパイス",
    "ひでん：あまスパイス",
    "チリソース",
    "ワサビソース",
    "カレーパウダー",
    "ホースラディッシュ",
    "ペッパー",
    "ソルト",
    "ビネガー",
    "オリーブオイル",
    "バター",
    "マヨネーズ",
    "ケチャップ",
    "マスタード"]

ings = [
  "ハラペーニョ",
  "バジル",
  "クレソン",
  "カットパイン",                                                            
    "わぎりリンゴ",                                                            
    "わぎりキウイ",                                                            
    "いちごスライス",                                                          
    "バナナスライス",
    "きりみフライ",
    "トルティージャ",
    "ヌードル",
    "ポテトサラダ",
    "ライス",
    "スライスエッグ",
    "スライスチーズ",
    "ハムスライス",
    "やきベーコン",
    "なまハム",
    "ガケガニスティック",
    "スモークきりみ",
    "トーフ",
    "やきチョリソー",
    "ハーブソーセージ",
    "ハンバーグ",
    "レタス",
    "トマトスライス",
    "カットミニトマト",
    "キュウリスライス",
    "ピクルススライス",
    "たまねぎスライス",
    "アーリーレッド",
    "ピーマンスライス",
    "あかパプリカスライス",
    "きパプリカスライス",
    "アボカド"]

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

spices_from_tsv = -> {
  tsv = CSV.read('spices.tsv', col_sep: "\t", headers: false)

  tsv.map do |row|
    {
      row[0] => row[2].split(',')
    }
  end.inject(&:merge)
}.call

ing_by_power_key = {}
tastes_by_power_key = {}

test_cases_from_tsv.map do |test|
  test[:powers].keys.each do |key|
    ing_by_power_key[key] ||= []
    ing_by_power_key[key].append(test[:ings])

    tastes_by_power_key[key] ||= []
    tastes = test[:ings].map { spices_from_tsv[_1] }
    tastes_by_power_key[key].append(tastes)
  end
end


pp ing_by_power_key
pp tastes_by_power_key

agg_by_name = ing_by_power_key.map do |k, v|
  values = v.flatten
  _agg = values.group_by { _1 }.map { |ki, vi| [ki, vi.count.to_f * 100 / values.count] }.sort_by { _1[1] }.to_h

  [k, _agg]
end.to_h

pp agg_by_name

agg_by_name = tastes_by_power_key.map do |k, v|
  values = v.flatten
  _agg = values.group_by { _1 }.map { |ki, vi| [ki, vi.count.to_f * 100 / values.count] }.sort_by { _1[1] }.to_h

  [k, _agg]
end.to_h

pp agg_by_name
