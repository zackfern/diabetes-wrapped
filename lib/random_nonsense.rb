class RandomNonsense
  ADJECTIVES = %w[
    annoying
    delicious
    gooey
    high
    low
    salty
    savory
    sticky
    sweet
    tasteless
    tasty
    wacky
  ]

  DIABETES_WORDS = %w[
    a1c
    basal
    bolus
    cgm
    correction
    diagnosis
    pump
    units
  ]

  FOODS = %w[
    apple
    avocado
    bagel
    banana
    bean
    blueberry
    bread
    broccoli
    brownie
    candy
    carrot
    cereal
    cherry
    chocolate
    coconut
    corn
    crab
    cucumber
    custard
    donut
    eggplant
    honey
    kiwi
    mango
    pasta
    pea
    peach
    pear
    pie
    pineapple
    potato
    ramen
    rice
    shrimp
    strawberry
    sushi
  ]

  def self.adjective_food_diabetes
    [
      ADJECTIVES[rand(0...ADJECTIVES.count)],
      FOODS[rand(0...FOODS.count)],
      DIABETES_WORDS[rand(0...DIABETES_WORDS.count)]
    ].join("-")
  end
end
