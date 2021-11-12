# frozen_string_literal: true

require 'climate_control'
require 'contentful_migrations/migrator'
require 'contentful_migrations/migration_proxy'
require 'contentful_migrations/migration_content_type'

RSpec.describe ContentfulMigrations::Migrator do
  describe 'class methods' do
    let(:env) do
      {
        CONTENTFUL_MANAGEMENT_ACCESS_TOKEN: management_access_token,
        CONTENTFUL_SPACE_ID: space_id
      }
    end
    let(:management_access_token) { 'management_access_token' }
    let(:space_id) { 'space_id' }

    around do |example|
      ClimateControl.modify(env) do
        example.run
      end
    end

    describe '.migrate' do
      let(:migrated) { double(:migrated) }

      before do
        expect(described_class).to receive(:new).and_return(double(:m, migrate: migrated))
      end

      it 'calls migrate' do
        expect(described_class.migrate).to eq(migrated)
      end
    end

    describe '.rollback' do
      let(:rolledback) { double(:rolledback) }

      before do
        expect(described_class).to receive(:new).and_return(double(:m, rollback: rolledback))
      end

      it 'calls migrate' do
        expect(described_class.rollback).to eq(rolledback)
      end
    end

    describe '.pending' do
      let(:pending_result) { double(:pending_result) }

      before do
        expect(described_class).to receive(:new).and_return(double(:m, pending: pending_result))
      end

      it 'calls migrate' do
        expect(described_class.pending).to eq(pending_result)
      end
    end
  end

  describe 'instance methods' do
    subject(:migrator) { described_class.new(**defaults) }

    let(:logger) { double(:logger) }
    let(:migrations_path) { 'spec/db/contentful_migrations' }
    let(:access_token) { 'my_access_token' }
    let(:space_id) { 'my_space_id' }
    let(:migration_content_type_name) { 'my_migrations' }
    let(:env_id) { 'my_env_id' }

    let(:defaults) do
      { migrations_path: migrations_path,
        access_token: access_token,
        space_id: space_id,
        migration_content_type_name: migration_content_type_name,
        logger: logger,
        env_id: env_id }
    end

    describe '#initialize' do
      it 'sets name and version' do

        expect(migrator.migrations_path).to eq migrations_path
        expect(migrator.access_token).to eq access_token
        expect(migrator.space_id).to eq space_id
        expect(migrator.migration_content_type_name).to eq migration_content_type_name
        expect(migrator.env_id).to eq env_id
      end

      it 'raises error when invalid path' do
        expect do
          described_class.new(**defaults.merge(migrations_path: 'bad/path'))
        end.to raise_error(ContentfulMigrations::Migrator::InvalidMigrationPath)
      end
    end

    describe '#migrate' do
      context 'when no migrations' do
        before do
          allow(migrator).to receive(:migrations).and_return([])
          expect(logger).to receive(:info)
        end

        it 'sets name and version' do
          expect(migrator.migrate).to eq(migrator)
        end
      end

      context 'when migrations' do
        let(:client) { double(:client) }
        let(:spaces) { double(:spaces) }
        let(:space) { double(:space) }
        let(:content_types) { double(:content_types) }
        let(:migration_content_type) { double(:migration_content_type) }
        let(:entries) { double(:entries, all: all) }
        let(:all) { [] }
        let(:migration) { double(:migration, version: 20_180_216_021_826, name: 'BuildTestContent') }

        before do
          allow(migrator).to receive(:migration_content_type).and_return(migration_content_type)
          allow(logger).to receive(:info)
        end

        it 'sets name and version' do
          expect(Contentful::Management::Client).to receive(:new).and_return(client)
          expect(client).to receive(:environments).with(space_id).and_return(space)
          expect(space).to receive(:find).with(env_id).and_return(space)
          expect(migration_content_type).to receive(:entries).and_return(entries)
          expect(ContentfulMigrations::MigrationProxy).to receive(:new).with(
            'BuildTestContent',
            20_180_216_021_826,
            'spec/db/contentful_migrations/20180216021826_build_test_content.rb',
            ''
          ).and_return(migration)
          expect(migration).to receive(:migrate).with(:up, client, space)
          expect(migration).to receive(:record_migration).with(migration_content_type)
          expect(migrator.migrate).to eq(migrator)
        end

        it 'sets @page_size during construction' do
          expect(migrator.instance_variable_get('@page_size')).to eq(1000)
        end

        it 'calls fetch_page when loading migrated records' do
          allow(migrator).to receive(:fetch_page).and_return([])
          expect(migrator).to receive(:fetch_page).once
          migrator.send(:migrated)
        end

        it 'pages through contentful records' do
          migrator.instance_variable_set('@page_size', 10)
          allow(migrator).to receive(:fetch_page).and_return((1..10).to_a, (1..9).to_a)
          expect(migrator).to receive(:fetch_page).twice
          migrator.send(:load_migrated)
        end
      end
    end
  end
end
