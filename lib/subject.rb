InitalPrior= 2e-4

class Subject
  include Mongoid::Document

  field :ouroboros_subject_id, type: String

  field :classification_count,  type: Float,  default: 0.0

  field :kind,                  type: String, default: "unknown"
  field :category,              type: String, default: "test"
  field :status,                type: String, default: "active"
  field :trajectory,            type: Array,  default: [InitalPrior]
  field :probability,           type: Float,  default: InitalPrior
  field :url,                   type: String

  index "ourobors_subject_id" => 1



  def update_prob(agent, answer)
    pl = agent.pl
    pd = agent.pd

    if answer=="LENS"
      likelihood = pl
      likelihood /= (pl*probability + (1-pd)*(1-probability))
    else
      likelihood = (1-pl)
      likelihood /= ((1-pl)*probability + pd*(1-probability))
    end

    #shouldnt have to do this ... not sure whats going on here.
    result = likelihood * probability
    set :probability, result

    push :trajectory,  result

    inc :classification_count , 1

    test_retirement
  end

  def test_retirement
    set(:status, "rejected") if probability < rejection_threshold
    set(:status, "detected") if probability > detection_threshold
  end

  def rejection_threshold
    1e-07
  end

  def detection_threshold
    0.95
  end

end
