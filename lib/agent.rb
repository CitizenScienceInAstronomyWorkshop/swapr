require 'mongoid'

Inital_pl = 0.5
Inital_pd = 0.5

class Agent
  include Mongoid::Document
  # field :id , type: Moped::BSON::ObjectId
  field :user_id,      type: String, default: nil
  field :pl,           type: Float,  default: Inital_pl
  field :pd,           type: Float,  default: Inital_pd

  field :contribution, type: Float,  default: 0

  field :counts,       type: Hash,   default: {"lens" => 0, "duds" =>0, "test" => 0, "total" => 0}
  field :history,      type: Array,  default: [{"pl" =>Inital_pl, "pd" => Inital_pd, "info" => 0}]
  field :contribution, type: Float,  default: 0

  index "user_id" => 1

  def update_contribution()
      plogp = [0,0]

      plogp[0] = 0.5*(pd+pl)*Math.log2(pd+pl)
      plogp[1] = 0.5*(1.0-pd+1.0-pl)*Math.log2(1.0-pd+1.0-pl)
      set :contribution, (plogp[0] + plogp[1])
  end

  def update_confusion(user_said, actual)

      match = (user_said==actual) ? 1 : 0


      if actual == "LENS"
        pl_new = (pl * counts["lens"] + match)/(1+counts["lens"])
        pl_new = [pl_new,pl_max].min
        pl_new = [pl_new,pl_min].max
        set :pl, pl_new

        inc "counts.lens", 1
        inc "counts.total", 1
      else

        pd_new = (pd*counts["duds"] + match)/(1+counts["duds"])
        pd_new = [pd_new,pd_max].min
        pd_new = [pd_new,pd_min].max
        set :pd, pd_new

        inc "counts.duds", 1
        inc "counts.total", 1
      end


      update_history

  end

  def update_history
    push :history, {"info" => update_contribution, "pl"=> pl, "pd" => pd }
  end


  def pl_max
    0.9
  end

  def pl_min
    0.1
  end

  def pd_max
    0.9
  end

  def pd_min
    0.1
  end

end
