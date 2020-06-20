import { Application } from "stimulus"
import { createConsumer } from "@rails/actioncable";

import { Controller } from "motion-client";

const application = Application.start();
const consumer = createConsumer();

application.register("motion", class extends Controller {
    getConsumer() {
        return consumer;
    }
});
