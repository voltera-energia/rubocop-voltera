# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Voltera::ScopePluralNaming, :config do
  it 'registers an offense for singular by_* scope with where hash' do
    expect_offense(<<~RUBY)
      scope :by_company_id, ->(company_id) { where(company_id: company_id) }
            ^^^^^^^^^^^^^^ Scope `:by_company_id` is plural-compatible but has a singular name. Consider renaming to `:by_company_ids`.
    RUBY
  end

  it 'does not register an offense for already-plural scope names' do
    expect_no_offenses(<<~RUBY)
      scope :by_company_ids, ->(company_ids) { where(company_id: company_ids) }
    RUBY
  end

  it 'does not register an offense for ILIKE scopes' do
    expect_no_offenses(<<~RUBY)
      scope :by_name_segment, ->(segment) { where('name ilike ?', "%\#{segment}%") }
    RUBY
  end
end
