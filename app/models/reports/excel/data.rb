class Reports::Excel::Data
  attr_reader :survey, :responses, :server_url, :file_name, :questions, :metadata

  def initialize(survey, questions, responses, server_url, metadata)
    @survey = survey
    @responses = responses
    @file_name = survey.filename_for_excel
    @questions = questions
    @metadata = metadata
    @server_url = server_url
  end

  def password
    # Length of password will be (5 * 2)
    @password ||= SecureRandom.hex(5)
  end
end
