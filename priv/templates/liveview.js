import Liveview from "./utilities/phoenix-liveview.js";

export default function () {
  let liveview = new Liveview("<%= @http_url %>", "<%= @websocket_url %>");

  liveview.connect(() => {
    liveview.send(
      "event",
      { type: "click", event: "nav", value: { page: "2" } },
      (_response) => {
        liveview.leave();
      }
    );
  });
}
