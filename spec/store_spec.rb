require('spec_helper')

describe(Store) do
  it { should have_and_belong_to_many(:brands) }
  it { should validate_presence_of(:name) }
end
