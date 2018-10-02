require 'rails_helper'

describe DaylyUpdateUnit do
  describe 'database schema' do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:code_greffe).of_type(:string) }
    it { is_expected.to have_db_column(:files_path).of_type(:string) }
    it { is_expected.to have_db_column(:status).of_type(:string) }
    it { is_expected.to have_db_column(:num_transmission).of_type(:integer) }
    it { is_expected.to have_db_column(:created_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime) }

    it { is_expected.to belong_to(:dayly_update) }
  end
end
