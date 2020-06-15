export default function dispatchEvent(target, name) {
    const event = new CustomEvent(name, {
        bubbles: true,
        cancelable: false
    });

    target.dispatchEvent(event);
}