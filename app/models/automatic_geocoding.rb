# encoding: UTF-8'
class AutomaticGeocoding < Sequel::Model

  MAX_RETRIES = 5

  many_to_one :table
  one_to_many :geocodings, order: :created_at

  def active
    AutomaticGeocoding.where("state IN ?", ['created', 'idle']).select do |ag|
      ag.table.data_last_modified > ag.ran_at
    end
  end # active

  def before_create
    super
    self.created_at ||= Time.now
    self.ran_at     ||= Time.now
    self.state      ||= 'created'
  end # before_create

  def before_save
    super
    self.updated_at = Time.now
  end # before_save

  def validate
    super
    validates_presence :table_id
  end # validate

  def enqueue
    Resque.enqueue(Resque::SynchronizationJobs, job_id: id)
  end # enqueue

  def run
    self.update(state: 'running')
    options = { 
      user_id:                table.owner.id,
      table_name:             table.name,
      formatter:              geocodings.first.formatter,
      automatic_geocoding_id: self.id
    }
      
    Geocoding.create(options).run!
    self.update(state: 'idle', ran_at: Time.now)
  rescue => e
    self.update(state: 'failed') and raise if retried_times > MAX_RETRIES
    self.update(retried_times: retried_times.to_i + 1, state: 'idle', run_at)
  end # run
end # AutomaticGeocoding
