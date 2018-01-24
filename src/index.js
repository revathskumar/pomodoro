import './main.css';
import { Main } from './Main.elm';
import registerServiceWorker from './registerServiceWorker';


(function() {
  if (Notification.permission !== "denied" && Notification.permission !== "granted") {
    Notification.requestPermission(function (permission) {
      // If the user accepts, let's create a notification
      if (permission === "") {
        var notification = new Notification("Hi there!");
      }
    });
  }
})();

const pomodoroApp = Main.embed(document.getElementById('root'));

pomodoroApp.ports.sendNotification.subscribe((message) =>{
    if (Notification.permission === "granted") {
        // If it's okay let's create a notification
        var notification = new Notification(message);
    }
    
    // Otherwise, we need to ask the user for permission
    else if (Notification.permission !== "denied") {
        Notification.requestPermission(function (permission) {
            // If the user accepts, let's create a notification
            if (permission === "granted") {
                var notification = new Notification(message);
            }
        });
    }
});

registerServiceWorker();
