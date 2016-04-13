require 'rails_helper'

RSpec.describe Formatter, type: :model do
  subject { FactoryGirl.build(:formatter) }

  let(:shot) {
    FactoryGirl.create(:shot).tap do |shot|
      allow(shot).to receive(:last_rank) { nil }
    end
  }

  let(:ranking) { FactoryGirl.create(:ranking) }

  describe '#format_item' do
    Formatter::ITEM_HANDLERS.to_a.reject(&:last).map(&:first).each do |key|
      it "formats #{key}" do
        val = shot.send(key).to_s
        subject.item = "#{key}: {{#{key}}}"
        expect(subject.format_item shot).to eq "#{key}: #{val}"
      end
    end

    it 'formats download_count_min and download_count_max as integer' do
      subject.item = '{{download_count_min}} - {{download_count_max}}'
      shot.download_count_min = 1_000_000
      shot.download_count_max = 5_000_000
      expect(subject.format_item shot).to eq '1000000 - 5000000'
    end

    it 'formats last_rank' do
      subject.item = '{{last_rank}}'
      expect(shot).to receive(:last_rank) { 7 }
      expect(subject.format_item shot).to eq '7'
    end

    it 'formats numbers with %' do
      subject.item = '{{rating%.2f}}'
      shot.rating = 4.321
      expect(subject.format_item shot).to eq '4.32'
    end

    it 'formats numbers with %to_' do
      subject.item = '{{rating_count%to_delimited}}'
      shot.rating_count = 3_142_419
      expect(subject.format_item shot).to eq '3,142,419'
    end

    it 'formats nil with |' do
      subject.item = '{{last_rank|--}}'
      expect(shot).to receive(:last_rank) { nil }
      expect(subject.format_item shot).to eq '--'
    end
  end

  describe '#format_ranking' do
    Formatter::RANKING_HANDLERS.to_a.reject(&:last).map(&:first).each do |key|
      it "formats #{key}" do
        val = ranking.send(key).to_s
        subject.item = "#{key}: {{#{key}}}"
        expect(subject.format_item ranking).to eq "#{key}: #{val}"
      end
    end

    it 'formats platform' do
      subject.pre = '{{platform}}'
      ranking.platform = 'googleplay'
      expect(subject.format_ranking ranking, :pre).to eq 'GooglePlay'
      ranking.platform = 'appstore'
      expect(subject.format_ranking ranking, :pre).to eq 'AppStore'
    end

    it 'formats items_count' do
      subject.pre = '{{items_count}}'
      ranking.shots = FactoryGirl.create_list(:shot, 12)
      expect(subject.format_ranking ranking, :pre).to eq '12'
    end

    it 'formats date with %' do
      subject.pre = '{{created_on%Ynen%-mgatsu%-dnichi}}'
      ranking.created_on = Date.new(2016, 4, 1)
      expect(subject.format_ranking ranking, :pre).to eq '2016nen4gatsu1nichi'
    end
  end
end