require 'rails_helper'

RSpec.describe User, type: :model do
  it { is_expected.to validate_presence_of :username }
  # emailのバリデーションはDeviseTokenAuth::Concerns::Userをincludeした際に追加されている模様
  it { is_expected.to validate_presence_of :email }
  it { is_expected.to validate_length_of(:tel).is_equal_to(11).allow_nil }
  it { is_expected.to validate_inclusion_of(:rank).in_array(['premium', 'normal']) }
  it { is_expected.to validate_presence_of :gender }
  it { is_expected.to validate_inclusion_of(:gender).in_array([0, 1, 2, 9]) }
end
