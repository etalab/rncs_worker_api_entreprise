module PopulatorHelper
  def skip_adresse?(options)
    # options[:fragment] represents the :adresse fields from incoming hash
    options[:fragment][:ligne_1].blank? &&
      options[:fragment][:ligne_2].blank? &&
      options[:fragment][:ligne_3].blank? &&
      options[:fragment][:code_postal].blank? &&
      options[:fragment][:ville].blank? &&
      options[:fragment][:code_commune].blank? &&
      options[:fragment][:pays].blank?
  end

  def skip_identite?(options)
    # options[:fragment] represents the :adresse fields from incoming hash
    options[:fragment][:nom_patronyme].blank? &&
      options[:fragment][:nom_usage].blank? &&
      options[:fragment][:pseudonyme].blank? &&
      options[:fragment][:prenoms].blank? &&
      options[:fragment][:date_naissance].blank? &&
      options[:fragment][:ville_naissance].blank? &&
      options[:fragment][:pays_naissance].blank? &&
      options[:fragment][:nationalite].blank?
  end
end
