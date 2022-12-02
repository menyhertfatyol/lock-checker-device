require 'door'

RSpec.describe Door do
  describe '#check_lock_state' do
    subject(:check_lock_state) { described_class.check_lock_state }

    context 'when door is open' do
      before { allow(RPi::GPIO).to receive(:high?).and_return true }

      it 'saves the open state of the door lock' do
        expect { check_lock_state }.to change(Doorlock.all, :size).by(1)
        expect(Doorlock.last.state).to eq 'open'
      end
    end

    context 'when door is locked' do
      before { allow(RPi::GPIO).to receive(:high?).and_return false }

      it 'saves the locked state of the door lock' do
        expect { check_lock_state }.to change(Doorlock.all, :size).by(1)
        expect(Doorlock.last.state).to eq 'locked'
      end
    end

    context 'when any error occurs' do
      before { allow(Doorlock).to receive(:create!).and_raise(StandardError) }

      it 'cleans up GPIO port' do
        expect(RPi::GPIO).to receive(:clean_up)
        expect { check_lock_state }.to raise_error StandardError
      end
    end

    context 'when custom GPIO pin is used' do
      subject(:check_lock_state) { described_class.check_lock_state(pin_num: 13) }

      it 'should work just fine' do
        expect(RPi::GPIO).to receive(:high?).with(13)
        check_lock_state
      end
    end
  end
end
