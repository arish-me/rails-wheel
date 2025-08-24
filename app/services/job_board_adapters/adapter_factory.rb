class JobBoardAdapters::AdapterFactory
  ADAPTERS = {
    "adzuna" => JobBoardAdapters::AdzunaAdapter,
    "remotive" => JobBoardAdapters::RemotiveAdapter
    # Add more adapters here as we implement them
    # 'arbeitnow' => JobBoardAdapters::ArbeitnowAdapter,
    # 'careerjet' => JobBoardAdapters::CareerjetAdapter,
    # 'reed' => JobBoardAdapters::ReedAdapter,
  }.freeze

  def self.create(integration)
    adapter_class = ADAPTERS[integration.provider]

    if adapter_class
      adapter_class.new(integration)
    else
      raise ArgumentError, "No adapter found for provider: #{integration.provider}"
    end
  end

  def self.supported_providers
    ADAPTERS.keys
  end

  def self.adapter_exists?(provider)
    ADAPTERS.key?(provider)
  end
end
