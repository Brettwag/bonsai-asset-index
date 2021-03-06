require 'spec_helper'

describe ExtensionsController do
  let(:extension) { create :extension }
  let(:params)    { {
    id:       extension.lowercase_name,
    username: extension.owner_name,
  } }

  before do
    sign_in create(:admin)
  end

  describe "index" do
    it "succeeds" do
      get :index
      expect(response).to be_successful
    end

    context "with the archs filter" do
      render_views

      let(:viable)            { true }
      let(:arch)              { 'my-arch' }
      let(:arch2)             { 'other-arch' }
      let(:config)            do
        {'builds' => [
          {"viable" => viable,
           "arch"   => arch},
        ]}
      end
      let(:extension_version) { create :extension_version, config: config }
      let!(:extension)        { extension_version.extension }

      it "includes matching results" do
        expect(extension.name).to be_present

        get :index, params: {archs: [arch]}
        expect(response.body).to include(extension.name)
      end

      it "excludes non-matching results" do
        expect(extension.name).to be_present

        get :index, params: {archs: [arch2]}
        expect(response.body).to_not include(extension.name)
      end

      context "non-viable results" do
        let(:viable) { false }

        it "excludes non-viable results" do
          expect(extension.name).to be_present

          get :index, params: {archs: [arch2]}
          expect(response.body).to_not include(extension.name)
        end
      end
    end

    context "with the platforms filter" do
      render_views

      let(:viable)            { true }
      let(:plat)              { 'my-plat' }
      let(:plat2)             { 'other-plat' }
      let(:config)            do
        {'builds' => [
          {"viable" => viable,
           "platform"   => plat},
        ]}
      end
      let(:extension_version) { create :extension_version, config: config }
      let!(:extension)        { extension_version.extension }

      it "includes matching results" do
        expect(extension.name).to be_present

        get :index, params: {platforms: [plat]}
        expect(response.body).to include(extension.name)
      end

      it "excludes non-matching results" do
        expect(extension.name).to be_present

        get :index, params: {platforms: [plat2]}
        expect(response.body).to_not include(extension.name)
      end

      context "non-viable results" do
        let(:viable) { false }

        it "excludes non-viable results" do
          expect(extension.name).to be_present

          get :index, params: {platforms: [plat2]}
          expect(response.body).to_not include(extension.name)
        end
      end
    end
  end

  describe "sync_repo" do
    it 'redirects to the extension page' do
      put :sync_repo, params: params
      expect(response).to redirect_to [extension, username: extension.owner_name]
    end

    it 'starts a sync job' do
      expect(SyncExtensionRepoWorker).to receive(:perform_async)
      put :sync_repo, params: params
    end
  end
end
