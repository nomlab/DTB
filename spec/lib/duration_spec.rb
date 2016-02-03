require 'rails_helper'

RSpec.describe Duration do
  describe '.new' do
    context 'positive case' do
      it 'makes duration from nils.' do
        expect(Duration.new(nil, nil).class).to eq(Duration)
      end

      it 'makes duration with any arguments.' do
        expect(Duration.new.class).to eq(Duration)
      end
    end

    context 'negative case' do
      it 'throws TypeError when arguments are not time.' do
        obj = Faker::Time.between(Time.current - 1, Time.current)
        expect{ Duration.new(obj, obj) }.to raise_error(TypeError)
      end
    end
  end

  describe '.make_from_date' do
    context 'positive case' do
      it 'makes duration from date object.' do
        date = Date.today
        duration = Duration.make_from_date(date)
        s_time = Time.zone.local(date.year, date.month, date.day)
        tomorrow = date.tomorrow
        e_time = Time.zone.local(tomorrow.year, tomorrow.month, tomorrow.day)
        expect(duration).to eq(Duration.new(s_time, e_time))
      end
    end

    context 'negative case' do
      it 'throws TypeError when arguments are not time.' do
        obj = Faker::Time.between(Time.current - 1, Time.current)
        expect{ Duration.make_from_date(obj) }.to raise_error(TypeError)
      end
    end
  end

  describe '#==' do
    before do
      @s_time = Time.current
      @e_time = Time.current + 1.minute
      @duration = Duration.new(@s_time, @e_time)
    end

    context 'positive case' do
      it 'compares start_time and end_time with other duration.' do
        expect(@duration == @duration).to eq(true)
        expect(@duration == Duration.new(@s_time, @e_time + 1.minute)).to eq(false)
        expect(@duration == Duration.new(@s_time + 1.minute, @e_time)).to eq(false)
      end
    end

    context 'negative case' do
      it 'throws TypeError when other is not duration.' do
        expect{ @duration == nil }.to raise_error(TypeError)
      end
    end
  end

  describe '#in?' do
    before do
      @s_time = Time.current
      @e_time = Time.current + 1.minute
      @duration = Duration.new(@s_time, @e_time)
    end

    context 'positive case' do
      it 'checks there are start_time and end_time into other duration.' do
        expect(@duration.in?(@duration)).to eq(true)
        expect(@duration.in?(Duration.new(@s_time, @e_time + 1.minute))).to eq(true)
        expect(@duration.in?(Duration.new(@s_time - 1.minute, @e_time))).to eq(true)
        expect(@duration.in?(Duration.new(@s_time + 1.minute, @e_time))).to eq(false)
        expect(@duration.in?(Duration.new(@s_time, @e_time - 1.minute))).to eq(false)
        expect(@duration.in?(Duration.new(@s_time + 1.minute, @e_time - 1.minute))).to eq(false)
      end
    end

    context 'negative case' do
      it 'throws TypeError when other is not duration.' do
        expect{ @duration.in?(nil) }.to raise_error(TypeError)
      end
    end
  end

  describe '#slice' do
    before do
      @s_time = Time.current
      @e_time = Time.current + 1.minute
      @duration = Duration.new(@s_time, @e_time)
    end

    context 'positive case' do
      context 'there are start_time and end_time into other duration.' do
        it 'return same duration.' do
          expect(@duration.slice(@duration)).to eq(@duration)
          expect(@duration.slice(Duration.new(@s_time, @e_time + 1.minute))).to eq(@duration)
          expect(@duration.slice(Duration.new(@s_time - 1.minute, @e_time))).to eq(@duration)
          expect(@duration.slice(Duration.new(@s_time - 1.minute, @e_time + 1.minute))).to eq(@duration)
        end
      end

      context 'there is not start_time or end_time into other duration.' do
        it 'slices myself by other duration.' do
          other = Duration.new(@s_time, @e_time - 1.second)
          expect(@duration.slice(other)).to eq(other)

          other = Duration.new(@s_time + 1.second, @e_time)
          expect(@duration.slice(other)).to eq(other)

          other = Duration.new(@s_time + 1.second, @e_time - 1.second)
          expect(@duration.slice(other)).to eq(other)
        end
      end

      context 'self do not overlap other duration.' do
        it 'returns nil.' do
          other = Duration.new(@s_time + 1.hour, @e_time + 1.hour)
          expect(@duration.slice(other)).to eq(nil)

          other = Duration.new(@s_time - 1.hour, @e_time - 1.hour)
          expect(@duration.slice(other)).to eq(nil)
        end
      end
    end

    context 'negative case' do
      it 'throws TypeError when other is not duration.' do
        expect{ @duration.slice nil }.to raise_error(TypeError)
      end
    end
  end

  describe '#merge' do
    before do
      @s_time = Time.current
      @e_time = Time.current + 1.minute
      @duration = Duration.new(@s_time, @e_time)
    end

    context 'positive case' do
      it 'merge with other duration.' do
        expect(@duration.merge(@duration)).to eq(@duration)

        other = Duration.new(@s_time, @e_time + 1.minute)
        expect(@duration.merge(other)).to eq(other)

        other = @duration.merge(Duration.new(@s_time - 1.minute, @e_time))
        expect(@duration.merge(other)).to eq(other)

        other = @duration.merge(Duration.new(@s_time - 1.minute, @e_time + 1.minute))
        expect(@duration.merge(other)).to eq(other)

        other = Duration.new(@s_time, @e_time - 1.minute)
        expect(@duration.merge(other)).to eq(@duration)

        other = @duration.merge(Duration.new(@s_time + 1.minute, @e_time))
        expect(@duration.merge(other)).to eq(@duration)

        other = @duration.merge(Duration.new(@s_time + 1.second, @e_time - 1.second))
        expect(@duration.merge(other)).to eq(@duration)
      end
    end

    context 'negative case' do
      it 'throws TypeError when other is not duration.' do
        expect{ @duration.merge(nil) }.to raise_error(TypeError)
      end
    end
  end

  describe '#overlap?' do
    before do
      @s_time = Time.current
      @e_time = Time.current + 1.minute
      @duration = Duration.new(@s_time, @e_time)
    end

    context 'positive case' do
      it 'checks start_time is less than other and end_time is greater than other.' do
        expect(@duration.overlap?(@duration)).to eq(true)
        expect(@duration.overlap?(Duration.new(@s_time + 1.second, @e_time))).to eq(true)
        expect(@duration.overlap?(Duration.new(@s_time, @e_time - 1.second))).to eq(true)
        expect(@duration.overlap?(Duration.new(@s_time + 1.second, @e_time - 1.second))).to eq(true)
        expect(@duration.overlap?(Duration.new(@s_time + 1.hour, @e_time + 1.hour))).to eq(false)
        expect(@duration.overlap?(Duration.new(@s_time - 1.hour, @e_time - 1.hour))).to eq(false)
      end
    end

    context 'negative case' do
      it 'throws TypeError when other is not duration.' do
        expect{ @duration.overlap?(nil) }.to raise_error(TypeError)
      end
    end
  end

  describe '#range' do
    before do
      @s_time = Time.current
      @e_time = Time.current + 1.minute
      @duration = Duration.new(@s_time, @e_time)
    end

    context 'positive case' do
      it 'returns range of date.' do
        expect(@duration.range).to eq((@s_time.to_date)..(@e_time.to_date))
      end
    end
  end

  describe '#to_seconds' do
    before do
      @s_time = Time.current
      @e_time = Time.current + 1.minute
      @duration = Duration.new(@s_time, @e_time)
    end

    context 'positive case' do
      it 'returns integer of duration length.' do
        expect(@duration.to_seconds).to eq(60)
      end
    end
  end

  describe '#to_s' do
    before do
      @s_time = Time.current
      @e_time = Time.current + 1.hour + 1.minute
      @duration = Duration.new(@s_time, @e_time)
    end

    context 'positive case' do
      it 'returns string by selected format.' do
        expect(@duration.to_s).to eq("#{@s_time} - #{@e_time}")
        expect(@duration.to_s(:hour)).to eq('01:01:00')
        expect(@duration.to_s(:minute)).to eq('61:00')
        expect(@duration.to_s(:second)).to eq('3660')
      end
    end

    context 'negative case' do
      it 'throws ArgumentError when argument is unknown.' do
        expect{ @duration.to_s(:foo) }.to raise_error(ArgumentError)
      end
    end
  end
end
