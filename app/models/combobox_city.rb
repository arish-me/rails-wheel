class ComboboxCity < OpenStruct
  def to_combobox_display
    "#{name}, #{subcountry}, #{country}"
  end

    def id
      "#{name}, #{subcountry}, #{country}"
    end
end
