document.addEventListener("DOMContentLoaded", (_) => {
  const observedChannelsEl = document.querySelector("#observed_channels")

  if (observedChannelsEl !== null) {
    observedChannelsEl.addEventListener('change', insertChannelAndChannelMembers)
  }
})


async function insertChannelAndChannelMembers(event) {
  const channelInfo = {
    id: event.target.value,
    name: event.target.options[event.target.selectedIndex].text
  }

  if (channelInfo.id === '') return

  displayView(createChannelView(channelInfo), 'test', 'afterbegin')

  const data = await fetchChannelMembers(channelInfo.id)
  const channelMembers = data.channel_members
  channelMembers.forEach(channelMember => {
    view = createUserView(channelMember)
    displayView(view, 'observed_channel', 'beforeend')
  })

}

function fetchChannelMembers(channelId) {
  return fetch(`/api/observed_members?channel_id=${channelId}`)
    .then((response) => {
      if (!response.ok) {
        return Promise.reject(new Error(`${response.status}: ${response.statusText}`));
      } else {
        return response.json()
      }
    })
}

function displayView(view, parentId, position) {
  const target = document.getElementById(parentId)
  target.insertAdjacentHTML(position, view)
}

function createChannelView(channelInfo) {
  return escapeHTML`
    <div id="observed_channel" class="flex-col my-3">
      <div>
        <p class="">${channelInfo.name}</p>
        <p>${channelInfo.name}</p>
      </div>
    </div>
    `
}

function createUserView(userInfo) {
  return escapeHTML`
    <div class="flex mb-1 px-4">
      <p class="flex items-center">${userInfo.name}</p>
      <img src="${userInfo.image_url}" alt="アカウントアイコン" class="ml-4 w-[50px] h-[50px]">
    </div>
    `
}

function escapeHTML(strings, ...values) {
  return strings.reduce((result, str, i) => {
    const value = values[i - 1];
    if (typeof value === "string") {
      return result + escapeSpecialChars(value) + str;
    } else {
      return result + String(value) + str;
    }
  });
}

function escapeSpecialChars(str) {
  return str
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#039;");
}


