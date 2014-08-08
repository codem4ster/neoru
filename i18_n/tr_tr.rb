class Neo::I18N::TrTr
  @dict = [
    ['Add File', 'Dosya Ekle'],
    ['Don\'t leave this field blank', 'Bu alanı boş bırakmayınız'],
    ['Please enter a valid email address', 'Geçerli bir eposta adresi giriniz'],
    ['This value should have exactly {{limit}} characters.','Bu değer, tam {{limit}} karakter olmalıdır.'],
    ['This value is too short. It should have {{limit}} characters or more.','Bu değer çok kısa. {{limit}} veya daha fazla karakter olmalıdır.'],
    ['This value is too long. It should have {{limit}} characters or less.', 'Bu değer çok uzun. {{limit}} karakter veya daha az olmalıdır.'],
    ['This value should be equal to {{compared_value}}','Bu alan {{compared_value}} ile aynı olmalıdır.'],
    ['You must set field parameter for EqualTo validator','EqualTo validator\'u için field alanı belirtilmemiş'],
    ['Form doesn\'t have a field named: {{field}}','Form böyle bir alan içermiyor: {{field}}']
  ]

  class << self
    attr_accessor :dict
  end
end