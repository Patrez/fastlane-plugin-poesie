describe Fastlane::Actions::PoesieAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The poesie plugin is working!")

      Fastlane::Actions::PoesieAction.run(nil)
    end
  end
end
