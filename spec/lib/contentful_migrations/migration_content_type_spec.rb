# frozen_string_literal: true

require 'byebug'
require 'contentful_migrations/migration_content_type'

RSpec.describe ContentfulMigrations::MigrationContentType do
  subject { described_class.new(**defaults) }

  let(:environment) { instance_double(Contentful::Management::Environment) }
  let(:content_type_name) { 'foos' }
  let(:defaults) { { environment: environment, content_type_name: content_type_name } }

  describe '#content_type' do
    subject { described_class.new(**defaults).content_type }

    let(:content_types) { double(Contentful::Management::ContentType) }
    let(:content_type) { instance_double(Contentful::Management::ContentType) }

    before do
      expect(environment).to receive(:content_types).and_return(content_types)
    end

    context 'when content type exists' do
      before do
        expect(content_types).to receive(:find).with(content_type_name).and_return(content_type)
      end

      it { is_expected.to eq content_type }
    end

    context 'when content type not exist' do
      let(:fields) { double(Contentful::Management::Field) }

      before do
        expect(content_types).to receive(:find).with(content_type_name).and_raise(StandardError)
        expect(content_types).to receive(:create).with(
          name: content_type_name,
          id: content_type_name,
          description: 'Migration Table for interal use only, do not delete'
        ).and_return(content_type)
        expect(content_type).to receive(:fields).and_return(fields)
        expect(fields).to receive(:create).with(id: 'version', name: 'version', type: 'Integer')
        expect(content_type).to receive(:save)
        expect(content_type).to receive(:publish)
      end

      it { is_expected.to eq content_type }
    end
  end
end
