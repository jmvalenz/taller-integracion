class Test < ActionMailer::Base
  default from: "from@example.com"

  def test
    mail :to => "jmvalenz@uc.cl", subject: "Test"
  end
end
