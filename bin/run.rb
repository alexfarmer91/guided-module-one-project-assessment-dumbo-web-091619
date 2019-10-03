require_relative '../config/environment'
require 'audio-playback'

# song = ['audio/by_your_side.ogg']
song = ['audio_choice2/rainy_mood.ogg']

AudioPlayback.play("#{song.sample}", is_looping: true)


interface = Interface.new
loggedInUser = interface.welcome()

while loggedInUser.nil?
    loggedInUser = interface.welcome()
end

interface.user = loggedInUser
interface.user.main_menu


