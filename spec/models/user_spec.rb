require 'rails_helper'

RSpec.describe User, type: :model do
  it { is_expected.to validate_presence_of :name }
  # emailのバリデーションはDeviseTokenAuth::Concerns::Userをincludeした際に追加されている模様
  it { is_expected.to validate_presence_of :email }
end
