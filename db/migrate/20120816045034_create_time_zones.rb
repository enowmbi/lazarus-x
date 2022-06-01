class CreateTimeZones < ActiveRecord::Migration[7.0]
  def self.up
    create_table :time_zones do |t|
      t.string :name
      t.string :code
      t.string :difference_type
      t.integer :time_difference

      t.timestamps
    end
    create_default_timezones
  end

  def self.down
    drop_table :time_zones
  end

  def self.create_default_timezones
    tlist = [["Greenwich Mean Time", "GMT", "+", 0],
             ["European Central Time", "ECT", "+", 3600],
             ["Eastern European Time", "EET", "+", 7200],
             ["Arabic Standard Time", "ART", "+", 7200],
             ["Eastern African Time", "EAT", "+", 10_800],
             ["Middle East Time", "MET", "+", 12_600],
             ["Near East Time", "NET", "+", 14_400],
             ["Pakistan Lahore Time", "PLT", "+", 18_000],
             ["Indian Standard Time", "IST", "+", 19_800],
             ["Bangladesh Standard Time", "BST", "+", 21_600],
             ["Vietnam Standard Time", "VST", "+", 25_200],
             ["China Taiwan Time", "CTT", "+", 28_800],
             ["Japan Standard Time", "JST", "+", 32_400],
             ["Australia Central Time", "ACT", "+", 34_200],
             ["Australia Eastern Time", "AET", "+", 36_000],
             ["Solomon Standard Time", "SST", "+", 39_600],
             ["New Zealand Standard Time", "NST", "+", 43_200],
             ["Midway Islands Time", "MIT", "-", 39_600],
             ["Hawaii Standard Time", "HST", "-", 36_000],
             ["Alaska Standard Time", "AST", "-", 32_400],
             ["Pacific Standard Time", "PST", "-", 28_800],
             ["Phoenix Standard Time", "PNT", "-", 25_200],
             ["Mountain Standard Time", "MST", "-", 25_200],
             ["Central Standard Time", "CST", "-", 21_600],
             ["Eastern Standard Time", "EST", "-", 18_000],
             ["Indiana Eastern Standard Time", "IET", "-", 18_000],
             ["Puerto Rico and US Virgin Islands Time", "PRT", "-", 14_400],
             ["Canada Newfoundland Time", "CNT", "-", 12_600],
             ["Argentina Standard Time", "AGT", "-", 10_800],
             ["Brazil Eastern Time", "BET", "-", 10_800],
             ["Central African Time", "CAT", "-", 3600]]

    tlist.each do |t|
      @tz = TimeZone.new
      @tz.name = t[0]
      @tz.code = t[1]
      @tz.difference_type = t[2]
      @tz.time_difference = t[3]
      @tz.save
    end
  end
end
