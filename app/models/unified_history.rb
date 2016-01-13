class UnifiedHistory < ActiveRecord::Base
  default_scope { order(created_at: :desc) }
  scope :file_histories, -> { where(type: 'FileHistory') }
  scope :web_histories, -> { where(type: 'WebHistory') }
  scope :extension, -> (ext) { where("path like '%.#{ext}'") }

  before_save :set_importance

  # history.duration が duration(s) と部分的に重複しているような histories を返す
  def self.overlap(duration)
    case duration
    when Duration
      where(['start_time >= ? and start_time <= ? or end_time >= ? and end_time <= ?',
             duration.start_time, duration.end_time,
             duration.start_time, duration.end_time])
    when Array
      durations = duration
      return none if (durs = durations).blank?
      tbl   = arel_table
      d     = durs.pop
      initial_nodes = tbl[:start_time].gteq(d.start_time).and(tbl[:start_time].lteq(d.end_time))
                      .or(tbl[:end_time].gteq(d.start_time).and(tbl[:end_time].lteq(d.end_time)))
      nodes = durs.inject(initial_nodes) do |nodes, d|
        nodes.or(tbl[:start_time].gteq(d.start_time).and(tbl[:start_time].lteq(d.end_time))
                  .or(tbl[:end_time].gteq(d.start_time).and(tbl[:end_time].lteq(d.end_time))))
      end
      where(nodes)
    else
      fail "Operation for #{duration.class} is undefined."
    end
  end

  def duration
    Duration.new(start_time, end_time)
  end

  def restore
    system "open #{path}"
  end

  private

  def set_importance
    self.importance = duration.length
  end
end

class WebHistory < UnifiedHistory
  def extension
    'html'
  end
end

class FileHistory < UnifiedHistory
  def extension
    path.split('/').last.split('.').last
  end

  # TODO: restore file by git
  # def restore
  # end
end
